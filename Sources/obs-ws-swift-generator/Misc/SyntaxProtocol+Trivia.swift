//
//  SyntaxProtocol+Trivia.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/21/26.
//

import Foundation
import SwiftSyntax

extension SyntaxProtocol {
    public func prepending(
        _ value: Trivia,
        to keyPath: WritableKeyPath<Self, Trivia>
    ) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value.appending(copy[keyPath: keyPath])
        return copy
    }
    
    public func appending(
        _ value: Trivia,
        to keyPath: WritableKeyPath<Self, Trivia>
    ) -> Self {
        var copy = self
        copy[keyPath: keyPath] = copy[keyPath: keyPath].appending(value)
        return copy
    }
}
