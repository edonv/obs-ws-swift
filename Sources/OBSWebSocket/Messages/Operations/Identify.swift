//
//  Identify.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

extension OBSOpData {
    /// Response to ``Hello`` message.
    ///
    /// If authentication is required by `obs-websocket`, `Identify` must contain an
    /// authentication string, along with PubSub subscriptions and other session parameters.
    ///
    /// - term Sent From: Freshly connected websocket client
    /// - term Sent To: `obs-websocket`
    public struct Identify: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .identify
        
        /// `rpcVersion` is the version number that the client would like the `obs-websocket` server to use.
        public let rpcVersion: Int
        public let authentication: String?
        
        /// A bitmask of ``OBSWS/Enums/EventSubscription`` items to subscribe to events and event
        /// categories at will.
        ///
        /// By default, all event categories are subscribed, except for events marked as high volume.
        /// High volume events must be explicitly subscribed to.
        public let eventSubscriptions: OBSWS.Enums.EventSubscription?
        
        internal init(
            rpcVersion: Int,
            authentication: String?,
            eventSubscriptions: OBSWS.Enums.EventSubscription? = nil
        ) {
            self.rpcVersion = rpcVersion
            self.authentication = authentication
            self.eventSubscriptions = eventSubscriptions
        }
    }
}
