//
//  WebSocketAsyncSession+OBSWS.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation
import MessagePacker
import WebSocketSession

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

extension WebSocketAsyncSession.Messages {
    /// Map each message to an ``OBSUntypedMessage``.
    func asOBSWSMessages<Decoder: OBSWSDecoder>(_ decoder: Decoder) -> some AsyncSequence<OBSUntypedMessage, any Error> {
        self.map { msg in
            let decodable: Data
            switch msg {
            case .string(let str):
                guard let data = str.data(using: .utf8) else {
                    #warning("TODO: new error for this")
                    throw OBSWebSocket.Errors.test
                }
                
                decodable = data
                
            case .data(let data):
                decodable = data
                
            @unknown default:
                #warning("TODO: new error for this")
                throw OBSWebSocket.Errors.test
            }
            
            return try decoder.decode(OBSUntypedMessage.self, from: decodable)
        }
    }
}
