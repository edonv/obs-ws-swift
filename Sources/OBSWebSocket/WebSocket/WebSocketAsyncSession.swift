//
//  WebSocketAsyncSession.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

public final class WebSocketAsyncSession: NSObject, @unchecked Sendable {
    public typealias Message = URLSessionWebSocketTask.Message
    public typealias CloseCode = URLSessionWebSocketTask.CloseCode
    
    /// The `URLRequest` used for creating an `URLSession` to start a connection.
    private let urlRequest: URLRequest
    
    /// The `URLSessionWebSocketTask` containing the active connection, if there is one.
    private var webSocketTask: URLSessionWebSocketTask!
    
    /// An `AsyncSequence` for subscribing to receiving WebSocket messages.
    private var _messages: Messages!
    public var messages: Messages {
        _messages
    }
    
    // MARK: - Public Initializers
    
    public init(request: URLRequest) {
        // Save `request`
        self.urlRequest = request
        
        super.init()
        
        // Create `webSocketTask`
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        self.webSocketTask = session.webSocketTask(with: request)
        
        self._messages = .init()
//         { _ in
//            self.disconnect(
//                with: .abnormalClosure,
//                reason: "Task no longer"
//            )
//        }
        
        // Start `webSocketTask`
        self.webSocketTask.resume()
    }
    
    public convenience init(url: URL) {
        self.init(request: .init(url: url))
    }
    
    deinit {
        self.disconnect(with: .goingAway, reason: "WebSocketAsyncSession is being deallocated.")
    }
    
    // MARK: - Connection Management
    
    /// Disconnects from the current session, if there is an active one.
    /// - Parameters:
    ///   - closeCode: `CloseCode` representation of reason for disconnecting.
    ///   - reason: `String` representation of reason for disconnecting.
    public func disconnect(
        with closeCode: CloseCode? = nil,
        reason: String? = nil
    ) {
        // No need to add a gaurd statement, because if one isn't active, webSocketTask will be nil.
        // If it's nil, calling cancel(with:reason:) using optional chaining will do nothing.
        webSocketTask.cancel(
            with: closeCode ?? .normalClosure,
            reason: (reason ?? "Closing connection").data(using: .utf8)
        )
    }
    
    // MARK: - Communication (In)
    
    private func listenOnce() {
        // Set up outputs of `webSocketTask`
        self.webSocketTask.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?._messages.yield(message)
            case .failure(let failure):
                let nsError = failure as NSError
                
                // Internal error thrown when socket is disconnected (code 57).
                // Replace with internal error type.
                if let posix = nsError as? POSIXError,
                   posix.code == .ENOTCONN,
                   let errorToThrow = self?.createConnectionClosedError() {
                    self?._messages.finish(throwing: errorToThrow)
                    return
                }
                
                self?._messages.yield(with: .failure(failure))
            }
            self?.listenOnce()
        }
    }
    
    // MARK: - Communication (Out)
    
    private func createConnectionClosedError() -> WebSocketError {
        .connectionClosed(code: self.webSocketTask.closeCode, reason: self.webSocketTask.closeReason)
    }
    
    private func ensureConnectionOpen() throws(WebSocketError) {
        guard self.webSocketTask.closeCode == .invalid else {
            throw createConnectionClosedError()
        }
    }
    
    private func _send(_ message: Message) async throws {
        try self.ensureConnectionOpen()
        try await webSocketTask.send(message)
    }
    
    /// Sends a `String` message to the connected WebSocket server/host.
    /// - Parameter message: The `String` message to send.
    public func send(_ message: String) async throws {
        try await _send(.string(message))
    }
    
    /// Sends a `Data` message to the connected WebSocket server/host.
    /// - Parameter message: The `Data` message to send.
    public func send(_ message: Data) async throws {
        try await _send(.data(message))
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketAsyncSession: URLSessionWebSocketDelegate {
    /// This function is called automatically by the delegate system when the WebSocket connection
    /// opens successfully.
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        listenOnce()
    }
    
//    /// This function is called automatically by the delegate system when the WebSocket connection
//    /// is closed.
//    public func urlSession(
//        _ session: URLSession,
//        webSocketTask: URLSessionWebSocketTask,
//        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
//        reason: Data?
//    ) {
////        self._messages.yield(with: .failure(.connectionClosed(code: closeCode, reason: reason)))
////        self._messages.yield(with: <#T##Result<Messages.Element, any Error>#>)
////        clearTaskData()
//        
////        let reasonStr = reason != nil ? String(data: reason!, encoding: .utf8) : nil
////        let event = WSEvent.disconnected(closeCode, reasonStr)
////        _subject.send(event)
//    }
}
