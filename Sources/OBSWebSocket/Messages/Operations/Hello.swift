//
//  Hello.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import CryptoKit

extension OBSOpData {
    /// First message sent from the server immediately on client connection. Contains authentication
    /// information if auth is required. Also contains RPC version for version negotiation.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Freshly connected websocket client
    public struct Hello: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .hello
        
        public let obsWebSocketVersion: String
        
        /// `rpcVersion` is a version number which gets incremented on each breaking change to the `obs-websocket`
        /// protocol. Its usage in this context is to provide the current rpc version that the server
        /// would like to use.
        public let rpcVersion: Int
        public let authentication: Authentication?
        
        public struct Authentication: Sendable, Hashable, Codable {
            public let challenge: String
            public let salt: String
        }
}
