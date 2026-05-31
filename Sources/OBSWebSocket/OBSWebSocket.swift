//
//  OBSWebSocket.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import WebSocketSession

import Synchronization
import MessagePacker
import AsyncAlgorithms

public final class OBSWebSocket: Sendable {
    public typealias UntypedMessage = OBSUntypedMessage
    public typealias Message = OBSMessage
    public typealias CloseCode = OBSWS.Enums.CloseCode
    
    // MARK: - Private Stored Properties
    
    private let _session: Mutex<WebSocketAsyncSession?>
    
    private let connectionDetails: Mutex<ConnectionDetails?>
    
    private var coders: AnyCoderPair {
        switch activeConnectionDetails?.encodingProtocol {
        case .msgPack: .msgPack
        default: .json
        }
    }
    
    private let handshakeDetails: Mutex<HandshakeDetails?>
    
    // MARK: - Public Computed Properties
    
    #warning("TODO: make this not a computed property so it can use .share()")
    private var messages: some AsyncSequence<OBSUntypedMessage, any Error> {
        let messages = _session.withLock(\.?.messages)
        
        guard let messages else {
            return AsyncOBSWebSocketMessages(nil)
        }
        
        return messages
            .asOBSWSMessages()
    }
    
    public var events: some AsyncSequence<OBSOpData.Event, any Error> {
        messages
            .compactMap { try? $0.as(OBSOpData.Event.self) }
            .map(\.data)
    }
    
    /// Current details of connection to `obs-websocket`.
    public var activeConnectionDetails: ConnectionDetails? {
        self.connectionDetails.withLock { $0 }
    }
    
    public var activeHandshakeDetails: HandshakeDetails? {
        self.handshakeDetails.withLock { $0 }
    }
    
    // MARK: - Public Initializers
    
    public init() {
        self._session = .init(nil)
        self.connectionDetails = .init(nil)
        self.handshakeDetails = .init(nil)
    }
    
    // MARK: - Connection Management
    
    /// Creates and starts a WebSocket connection.
    /// - Parameter request: The connection data to connect to.
    public func connect(
        with connectionData: ConnectionDetails,
        subscribingTo eventSubscription: OBSWS.Enums.EventSubscription? = nil
    ) async throws(Errors) {
        let (session, details) = try await Self.initiateHandshake(
            with: connectionData,
            subscribingTo: eventSubscription
        )
        
        self._session.withLock { $0 = session }
        self.connectionDetails.withLock { $0 = connectionData }
        self.handshakeDetails.withLock { $0 = details }
    }
    
    private static func initiateHandshake(
        with connectionData: ConnectionDetails,
        subscribingTo eventSubscription: OBSWS.Enums.EventSubscription?
    ) async throws(Errors) -> (session: WebSocketAsyncSession, details: HandshakeDetails) {
        guard let request = connectionData.urlRequest else {
            #warning("TODO: make new more specific error case")
            throw .test
        }
        
        let encodingProtocol = request.webSocketProtocolHeader
        
        // START CONNECTION
        let session = WebSocketAsyncSession(request: request)
        
        // Use local `session` because `self.session` hasn't been set yet
        let messages = session.messages
            .asOBSWSMessages()
        
        do {
            // 1 - Wait for `Hello` message from OBS-WS
            // Once the connection is upgraded, the websocket server will immediately send an OpCode 0 `Hello` message to the client.
            // - The client listens for the `Hello` and responds with an OpCode 1 `Identify` containing all appropriate session parameters.
            let helloUntyped = try await messages
                .first(where: { $0.operation == .hello })
            
            guard let hello = try? helloUntyped?.as(OBSOpData.Hello.self) else {
                #warning("TODO: custom error")
                throw Errors.test
            }
            
            // 2 - Convert `Hello` to `Identify`
            //   - If there is an `authentication` field in the `messageData` object, the server requires authentication, and the steps in Creating an authentication string should be followed.
            //   - If there is no `authentication` field, the resulting `Identify` object sent to the server does not require an authentication string.
            //   - The client determines if the server's rpcVersion is supported, and if not it provides its closest supported version in Identify.
            let identify = try hello.toIdentify(
                password: connectionData.password,
                subscribingTo: eventSubscription
            )
            
            // 3 - Send `Identify`
            // - The server receives and processes the `Identify` sent by the client.
            //   - If authentication is required and the Identify message data does not contain an authentication string, or the string is not correct, the connection is closed with WebSocketCloseCode::AuthenticationFailed
            //   - If the client has requested an rpcVersion which the server cannot use, the connection is closed with WebSocketCloseCode::UnsupportedRpcVersion. This system allows both the server and client to have seamless backwards compatability.
            //  - If any other parameters are malformed (invalid type, etc), the connection is closed with an appropriate close code.
            try await session.send(identify, encodingProtocol: encodingProtocol)
            
            // 4 - Receive `Identified` message to confirm successful connection
            // - Once identification is processed on the server, the server responds to the client with an OpCode 2 Identified.
            // - The client will begin receiving events from obs-websocket and may now make requests to obs-websocket.
            let identifiedUntyped = try await messages
                .first(where: { $0.operation == .identified })
            
            guard let identified = try? identifiedUntyped?.as(OBSOpData.Identified.self) else {
                #warning("TODO: custom error")
                throw Errors.test
            }
            
            // Return session and details if successful
            return (
                session,
                .init(
                    eventSubscription: eventSubscription,
                    obsWebSocketVersion: hello.data.obsWebSocketVersion,
                    rpcVersion: identified.data.negotiatedRpcVersion
                )
            )
        } catch let error as Errors {
            throw error
        } catch let error as WebSocketError {
            throw .wsError(error)
        } catch {
            #warning("TODO: custom error")
            print("caught error:", error)
            throw .test
        }
    }
    
    /// Disconnects from the current session, if there is an active one.
    /// - Parameters:
    ///   - closeCode: `CloseCode` representation of reason for disconnecting.
    ///   - reason: `String` representation of reason for disconnecting.
    public func disconnect(
        with closeCode: CloseCode? = nil,
        reason: String? = nil
    ) {
        self._session.withLock {
            $0?.disconnect(
                // despite OBSWS's close codes aren't standard, Swift let's them be converted to
                // a URLSessionWebSocketTask.CloseCode, but only when forced.
                // it fails when not force unwrapped
                with: closeCode.map { .init(rawValue: $0.rawValue)! },
                reason: reason)
        }
        
        self.clearTaskData()
    }
    
    /// Cleans up properties after closing a connection.
    private func clearTaskData() {
        self.connectionDetails.withLock { $0 = nil }
        self.handshakeDetails.withLock { $0 = nil }
    }
    
    public enum Errors: Error {
        case test
        case webSocketError(WebSocketError)
        case obsWebSocketClosed(OBSWS.Enums.CloseCode, reason: String?)
        
        fileprivate static func wsError(_ error: WebSocketError) -> Self {
            switch error {
            case .connectionClosed(let code, let reason):
                if let code = OBSWS.Enums.CloseCode(rawValue: code) {
                    return .obsWebSocketClosed(code, reason: reason)
                }
            }
            
            return .webSocketError(error)
        }
    }
}
