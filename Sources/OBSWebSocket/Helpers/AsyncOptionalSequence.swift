//
//  AsyncOptionalSequence.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/30/26.
//

import Foundation
import AsyncAlgorithms

/// An internal helper `AsyncSequence` type.
///
/// `AsyncOptionalSequence` supports initialization from a `nil` value, creating an `AsyncSequence` that ends immediately.
internal struct AsyncOptionalSequence<Base: AsyncSequence>: AsyncSequence {
    typealias Element = Base.Element
    typealias Failure = Base.Failure
    
    enum Content {
        case empty
        case base(Base)
        
        var iterator: Base.AsyncIterator? {
            switch self {
            case .empty: nil
            case .base(let base): base.makeAsyncIterator()
            }
        }
    }
    
    private var content: Content
    
    init(_ base: Base?) {
        if let base {
            self.content = .base(base)
        } else {
            self.content = .empty
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(content.iterator)
    }
    
    struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var base: Base.AsyncIterator?
        
        @inlinable
        init(_ base: Base.AsyncIterator?) {
            self.base = base
        }
        
        @inlinable
        mutating func next() async rethrows -> Element? {
            while let element = try await base?.next() {
                return element
            }
            
            return nil
        }
    }
}

extension AsyncSequence {
    /// Creates an `AsyncOptionalSequence` from another `AsyncSequence`.
    var optional: AsyncOptionalSequence<Self> {
        .init(self)
    }
}
