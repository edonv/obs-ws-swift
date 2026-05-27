//
//  WebSocketSessionMessages.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

extension WebSocketSession {
    #warning("TODO: make session generic so Messages could be swapped for a different monitoring method")
    public struct Messages: AsyncSequence, Sendable {
        public typealias Stream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Swift.Error>
        public typealias AsyncIterator = Stream.Iterator
        public typealias Element = Message
        
        private let stream: Stream
        private let continuation: Stream.Continuation
        
        public init(
            onTermination: (@Sendable (Stream.Continuation.Termination) -> Void)? = nil
        ) {
            // Set `stream`/`continuation`
            (self.stream, self.continuation) = Stream.makeStream(throwing: Swift.Error.self)
            
            self.continuation.onTermination = onTermination
        }
        
        internal func yield(_ element: Element) {
            self.continuation.yield(element)
        }
        
        internal func yield(with result: Result<Element, Swift.Error>) {
            self.continuation.yield(with: result)
        }
        
        internal func finish(throwing error: Error) {
            self.continuation.finish(throwing: error)
        }
        
        public func makeAsyncIterator() -> AsyncIterator {
            return stream.makeAsyncIterator()
        }
    }
}
