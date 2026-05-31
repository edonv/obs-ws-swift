//
//  AsyncOBSUntypedMessageSequence.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/31/26.
//

import Foundation

/// An internal helper `AsyncSequence` type.
///
/// `AsyncOBSUntypedMessageSequence` internally maps basic `URLSessionWebSocketTask.Message`s to OBS WebSocket-specific messages.
public struct AsyncOBSUntypedMessageSequence<Base: AsyncSequence>: AsyncSequence, Sendable where Base: Sendable, Base.Element == URLSessionWebSocketTask.Message {
    typealias Decoder = JSONDecoder
    
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(base.makeAsyncIterator())
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var base: Base.AsyncIterator
        
        init(_ base: Base.AsyncIterator) {
            self.base = base
        }
        
        public mutating func next() async throws -> OBSUntypedMessage? {
            while let msg = try await base.next() {
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
                
                guard let obsMsg = try? Decoder().decode(OBSUntypedMessage.self, from: decodable) else { continue }
            }
            
            return nil
        }
    }
}
