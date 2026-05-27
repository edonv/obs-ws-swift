//
//  URLRequest+Extension.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

extension URLRequest {
    static let encodingProtocolHeaderKey = "Sec-WebSocket-Protocol"
    
    public var webSocketProtocolHeader: OBSWebSocket.Connection.MessageEncoding? {
        get {
            self.value(forHTTPHeaderField: URLRequest.encodingProtocolHeaderKey)
                .flatMap { .init(rawValue: $0) }
        } mutating set {
            self.setValue(newValue?.rawValue, forHTTPHeaderField: URLRequest.encodingProtocolHeaderKey)
        }
    }
}
