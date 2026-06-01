//
//  AsyncSendableSequence.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/31/26.
//

import Foundation

/// Syntactic sugar equivalent to `Sendable & AsyncSequence<Element, Failure>`.
public typealias AsyncSendableSequence<Element, Failure> = Sendable & AsyncSequence<Element, Failure> where Element: Sendable, Failure: Error
