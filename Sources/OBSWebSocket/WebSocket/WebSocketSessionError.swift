//
//  WebSocketSessionError.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation

extension WebSocketSession {
    public enum Error: Swift.Error {
        case connectionClosed(code: Int, reason: String?)
        
        internal static func connectionClosed(code: CloseCode, reason: Data?) -> Self {
            .connectionClosed(
                code: code.rawValue,
                reason: reason.flatMap { String(data: $0, encoding: .utf8) }
            )
        }
    }
}
