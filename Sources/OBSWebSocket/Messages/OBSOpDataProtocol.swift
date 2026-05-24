//
//  OBSOpDataProtocol.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// All `OBSMessage` bodies (``OBSMessageProtocol/data``) conform to this.
///
/// This is the low-level message data which may be sent to and from `obs-websocket`.
public protocol OBSOpDataProtocol: Sendable, Hashable, Codable {
    /// The enum/numerical representation of the message type.
    static var opCode: OBSWS.Enums.OpCode { get }
}
