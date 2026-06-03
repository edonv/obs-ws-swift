//
//  OBSWebSocket.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import WebSocketSession
import HelperTypes
import JSONValue

import Synchronization
import MessagePacker
import AsyncAlgorithms
import Timeout

public final class OBSWebSocket: Sendable {
    public typealias UntypedMessage = OBSUntypedMessage
    public typealias Message = OBSMessage
    public typealias CloseCode = OBSWS.Enums.CloseCode
    
    // MARK: - Private Stored Properties
    
    private let _session: Mutex<WebSocketAsyncSession?>
    
    private let connectionDetails: Mutex<ConnectionDetails?>
    private let handshakeDetails: Mutex<HandshakeDetails?>
    
    private var coders: AnyCoderPair {
        switch activeConnectionDetails?.encodingProtocol {
        case .msgPack: .msgPack
        default: .json
        }
    }
    
    // MARK: - Public Computed Properties
    
    public var isConnected: Bool {
        _session.withLock { $0 != nil }
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
            
            guard let hello = try? helloUntyped?.as(OBS.OpData.Hello.self) else {
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
            
            guard let identified = try? identifiedUntyped?.as(OBS.OpData.Identified.self) else {
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
        #warning("TODO: not actually passing through the correct close code")
        self._session.withLock { $0 }?.disconnect(
            // despite OBSWS's close codes aren't standard, Swift let's them be converted to
            // a URLSessionWebSocketTask.CloseCode, but only when forced.
            // it fails when not force unwrapped
            with: closeCode.map { URLSessionWebSocketTask.CloseCode(rawValue: $0.rawValue)! },
            reason: reason
        )
        
        self.clearTaskData()
    }
    
    /// Cleans up properties after closing a connection.
    private func clearTaskData() {
        self.connectionDetails.withLock { $0 = nil }
        self.handshakeDetails.withLock { $0 = nil }
    }
    
    private func ensureConnectionOpen() throws(Errors) -> WebSocketAsyncSession {
        guard let session = self._session.withLock(\.?.self) else {
            throw .noActiveConnection
        }
        
        return session
    }
    
    // MARK: - Communication (In)
    
    #warning("TODO: replace `any Error` with custom error type")
    private var messages: some AsyncSendableSequence<OBSUntypedMessage, any Error> {
        return _session
            .withLock(\.?.messages)?.asOBSWSMessages().optional ?? .init(nil)
    }
    
    public var events: some AsyncSendableSequence<OBS.OpData.Event, any Error> {
        messages.events()
    }
    
    public func events<E: OBSEvent>(
        ofType type: E.Type,
        isIncluded: (@Sendable (OBS.OpData.Event) throws -> Bool)? = nil
    ) -> some AsyncSendableSequence<E, any Error> {
        messages.events(ofType: type.self, isIncluded: isIncluded)
    }
    
    // MARK: - Communication (Out)
    
    @discardableResult
    public func send<R: OBSRequest>(
        _ request: R,
        withID id: UUID = UUID()
    ) async throws -> R.Response {
        let session = try ensureConnectionOpen()
        
        let requestMessage = try OBSMessages.Request(data: .init(request, id: id.uuidString))
        try await session
            .send(
                requestMessage,
                encodingProtocol: self.connectionDetails.withLock(\.?.encodingProtocol)
            )
        
        // Throw error if 5 seconds passes without finding a `RequestResponse` message
        let reqRespMsg = try await withThrowingTimeout(after: .now.advanced(by: .seconds(5))) {
            try await self.messages
                .compactMap { msg in
                    try? msg.as(OBS.OpData.RequestResponse.self)
                }
                .first {
                    $0.data.type == R.requestType
                    && $0.data.id == id.uuidString
                }
        }
        
        guard let reqRespMsg else {
            throw Errors.test
        }
        
        guard reqRespMsg.data.status.result else {
            throw Errors.requestFailed(
                type: requestMessage.data.type,
                id: requestMessage.data.id,
                request: requestMessage.data.data,
                response: reqRespMsg.data.data,
                status: reqRespMsg.data.status
            )
        }
        
        return try reqRespMsg.data.asResponse(ofType: R.self)
    }
    
    // MARK: - Errors
    
    public enum Errors: Error {
        case test
        case webSocketError(WebSocketError)
        case obsWebSocketClosed(OBSWS.Enums.CloseCode, reason: String?)
        case noActiveConnection
        case requestFailed(type: OBSWS.Requests.AllTypes, id: String, request: JSONValue?, response: JSONValue?, status: OBS.OpData.RequestResponse.Status)
        
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
