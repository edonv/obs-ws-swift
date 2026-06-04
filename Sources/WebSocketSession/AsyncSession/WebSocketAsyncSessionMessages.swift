//
//  WebSocketAsyncSessionMessages.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

extension WebSocketAsyncSession {
    #warning("TODO: make session generic so Messages could be swapped for a different monitoring method")
    package struct Messages: AsyncSequence, Sendable {
        package typealias Stream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Swift.Error>
        package typealias AsyncIterator = Stream.Iterator
        package typealias Element = Message
        
        private let stream: Stream
        private let continuation: Stream.Continuation
        
        package init(
            onTermination: (@Sendable (Stream.Continuation.Termination) -> Void)? = nil
        ) {
            // Set `stream`/`continuation`
            (self.stream, self.continuation) = Stream.makeStream(throwing: Swift.Error.self)
            
            self.continuation.onTermination = onTermination
        }
        
        internal func yield(_ element: Element) {
            if WebSocketAsyncSession.debug {
                print("yield(_:)", element)
            }
            self.continuation.yield(element)
        }
        
        internal func yield(with result: Result<Element, Swift.Error>) {
            if WebSocketAsyncSession.debug {
                print("yield(with:)", result)
            }
            self.continuation.yield(with: result)
        }
        
        internal func finish(throwing error: Error) {
            if WebSocketAsyncSession.debug {
                print("finish(throwing:)", error)
            }
            self.continuation.finish(throwing: error)
        }
        
        package func makeAsyncIterator() -> AsyncIterator {
            return stream.makeAsyncIterator()
        }
    }
}
