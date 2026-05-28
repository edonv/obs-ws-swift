//
//  WebSocketSessionProtocol.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

public protocol WebSocketSessionProtocol: NSObject, URLSessionWebSocketDelegate {
    typealias Message = URLSessionWebSocketTask.Message
    typealias CloseCode = URLSessionWebSocketTask.CloseCode
    
    init(request: URLRequest)
    
    func disconnect(
        with closeCode: CloseCode?,
        reason: String?
    )
    
    /// Sends a `String` message to the connected WebSocket server/host.
    /// - Parameter message: The `String` message to send.
    func send(_ message: String) async throws
    
    /// Sends a `Data` message to the connected WebSocket server/host.
    /// - Parameter message: The `Data` message to send.
    func send(_ message: Data) async throws
}

extension WebSocketSessionProtocol {
    public init(url: URL) {
        self.init(request: .init(url: url))
    }
}
