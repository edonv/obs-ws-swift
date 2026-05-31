//
//  WebSocketAsyncSession+OBSWS.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation
import MessagePacker
import WebSocketSession

// MARK: - WebSocketAsyncSession.send()

extension WebSocketAsyncSession {
    internal func send<M: OBSMessageProtocol>(
        _ message: M,
        encodingProtocol: OBSWebSocket.ConnectionDetails.MessageEncoding?
    ) async throws {
        let data: Data
        
        switch encodingProtocol {
        case .msgPack:
            data = try MessagePackCoders().encoder.encode(message)
        default:
            data = try JSONCoders().encoder.encode(message)
        }
        
        try await self.send(obsWSData: data, encodingProtocol: encodingProtocol)
    }
    
    private func send(
        obsWSData data: Data,
        encodingProtocol: OBSWebSocket.ConnectionDetails.MessageEncoding?
    ) async throws {
        switch encodingProtocol {
        case .msgPack:
            try await self.send(data)
        default:
            try await self.send(String(data: data, encoding: .utf8)!)
        }
    }
}

// MARK: - WebSocketAsyncSession.Messages

typealias AsyncOBSWebSocketMessages = AsyncOptionalSequence<AsyncOBSUntypedMessageSequence<WebSocketAsyncSession.Messages>>

extension WebSocketAsyncSession.Messages {
    /// Map each message to an ``OBSUntypedMessage``.
    func asOBSWSMessages() -> AsyncOBSWebSocketMessages {
        AsyncOBSUntypedMessageSequence(self, throwIfIncompatible: false)
            .optional
    }
}
