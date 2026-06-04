//
//  WebSocketAsyncSessionTaskLocals.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 6/4/26.
//

import Foundation

extension WebSocketAsyncSession {
    /// Set this to `true` to enable debug print-outs.
    ///
    /// Wrap usages of `WebSocketAsyncSession` with `WebSocketAsyncSession.$debug.withValue(true) { ... }` to enable debugging.
    @TaskLocal
    public static var debug: Bool = false
}
