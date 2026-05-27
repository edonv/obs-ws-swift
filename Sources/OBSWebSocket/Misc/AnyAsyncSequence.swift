//
//  AnyAsyncSequence.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation

//struct AnyAsyncSequence<Element, Failure: Error>: AsyncSequence, AsyncIteratorProtocol {
////    typealias Element = <#T##Type#>
//    
////    private let iterator: AsyncIterator
//    let callback: @Sendable () async throws -> Element?
//    
//    init<I: AsyncIteratorProtocol>(iterator: inout I) where I.Element == Element {
//        self.callback = { async throws -> Element? in
//            try await iterator.next()
//        }
////            .init(callback: {
////            try await iterator.next()
////        })
//    }
//    
//    func makeAsyncIterator() -> Self {
//        self
//    }
//    
//    func next() async throws -> Element? {
//        try await callback()
//    }
//}
