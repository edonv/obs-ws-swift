//
//  OBSOpDataProtocol.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// All ``OBS/Message`` bodies (``OBSMessageProtocol/data``) conform to this.
///
/// This is the low-level message data which may be sent to and from `obs-websocket`.
public protocol OBSOpDataProtocol: Sendable, Hashable, Codable {
    /// The enum/numerical representation of the message type.
    static var opCode: OBSWS.Enums.OpCode { get }
}

extension OBS {
    /// Namespace for all ``OBS/Message`` body types.
    ///
    /// Adapted from the [official documentation](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#message-types-opcodes).
    public enum OpData {}
}
