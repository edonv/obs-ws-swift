//
//  OBSWebSocketEvents.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation
import HelperTypes

extension OBSWebSocket {
    public struct Events<Base: AsyncSequence>: AsyncSequence, Sendable where Base: Sendable, Base.Element == OBS.UntypedMessage {
        public typealias Element = OBS.OpData.Event
        
        let base: Base
        private let isIncluded: @Sendable (Element) throws -> Bool

        internal init(
            _ base: Base,
            isIncluded: @escaping @Sendable (Element) throws -> Bool
        ) {
            self.base = base
            self.isIncluded = isIncluded
        }
        
        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(
                iterator: base.makeAsyncIterator(),
                isIncluded: isIncluded
            )
        }
        
        public struct AsyncIterator: AsyncIteratorProtocol {
            var iterator: Base.AsyncIterator
            let isIncluded: @Sendable (Element) throws -> Bool
            
            public mutating func next() async throws -> Element? {
                while let msg = try await iterator.next() {
                    guard let eventMsg = try? msg.as(OBS.OpData.Event.self),
                          try self.isIncluded(eventMsg.data) else { continue }
                    return eventMsg.data
                }
                
                return nil
            }
        }
    }
}

extension AsyncSequence where Self: Sendable, Element == OBS.UntypedMessage {
    public func events(
        isIncluded: (@Sendable (_ event: OBS.OpData.Event) throws -> Bool)? = nil
    ) -> OBSWebSocket.Events<Self> {
        .init(self, isIncluded: isIncluded ?? { _ in true })
    }
    
    public func events<E: OBSEvent>(
        ofType type: E.Type,
        isIncluded: (@Sendable (_ event: OBS.OpData.Event) throws -> Bool)? = nil
    ) -> some AsyncSendableSequence<E, any Error> {
        OBSWebSocket.Events(self, isIncluded: isIncluded ?? { _ in true })
            .compactMap { try? $0.asEvent(ofType: E.self) }
    }
}
