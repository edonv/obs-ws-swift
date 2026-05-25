//
//  OBSUntypedMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

/// A general type used for easier receipt of messages without having to cast immediately.
public struct OBSUntypedMessage: OBSMessageProtocol {
    public let operation: OBSWS.Enums.OpCode
    
    /// The body of the message.
    ///
    /// Its structure varies based on the type of message (``OBSUntypedMessage/operation``).
    public let data: JSONValue
    
    public init(
        operation: OBSWS.Enums.OpCode,
        data: JSONValue
    ) {
        self.operation = operation
        self.data = data
    }
}
