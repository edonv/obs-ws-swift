//
//  WebSocketError.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation

public enum WebSocketError: Swift.Error {
    public typealias CloseCode = URLSessionWebSocketTask.CloseCode
    
    case connectionClosed(code: Int, reason: String?)
    
    internal static func connectionClosed(code: CloseCode, reason: Data?) -> Self {
        .connectionClosed(
            code: code.rawValue,
            reason: reason.flatMap { String(data: $0, encoding: .utf8) }
        )
    }
}
