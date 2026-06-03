//
//  MessageProtocol.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// A protocol shared between types of messages sent to and from OBS WebSocket.
public protocol OBSMessageProtocol: Sendable, Hashable, Codable {
    associatedtype Body: Sendable, Hashable, Codable
    
    /// The type of message.
    var operation: OBS.Enums.OpCode { get }
    /// The body of the message.
    var data: Body { get }
    
    init(operation: OBS.Enums.OpCode, data: Body)
}

private enum OBSMessageProtocolCodingKeys: String, CodingKey {
    case operation = "op"
    case data = "d"
}

extension OBSMessageProtocol {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: OBSMessageProtocolCodingKeys.self)
        
        try container.encode(self.operation, forKey: .operation)
        try container.encode(self.data, forKey: .data)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: OBSMessageProtocolCodingKeys.self)
        
        self.init(
            operation: try container.decode(OBS.Enums.OpCode.self, forKey: .operation),
            data: try container.decode(Body.self, forKey: .data)
        )
    }
}
