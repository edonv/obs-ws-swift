//
//  OBSMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

/// A type used for sending and receiving information to and from OBS.
public struct OBSMessage<Body: OBSOpDataProtocol>: OBSMessageProtocol {
    public let operation: OBSWS.Enums.OpCode
    public let data: Body
    
    public init(
        operation: OBSWS.Enums.OpCode,
        data: Body
    ) {
        self.operation = operation
        self.data = data
    }
    
    public init(data: Body) {
        self.operation = Body.opCode
        self.data = data
    }
    
    func untyped() throws -> OBSUntypedMessage {
        .init(
            operation: operation,
            data: try JSONValue.fromCodable(data)
        )
    }
}
