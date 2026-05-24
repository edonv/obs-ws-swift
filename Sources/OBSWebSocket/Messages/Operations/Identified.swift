//
//  Identified.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

extension OBSOpData {
    /// The ``OpDataTypes/Identify`` request was received and validated, and the connection is now ready for
    /// normal operation.
    ///
    /// If rpc version negotiation succeeds, the server determines the RPC version to be used
    /// and gives it to the client as `negotiatedRpcVersion`.
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Freshly identified client
    public struct Identified: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .identified
        
        public let negotiatedRpcVersion: Int
    }
}
