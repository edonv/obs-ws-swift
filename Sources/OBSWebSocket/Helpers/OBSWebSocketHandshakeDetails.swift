//
//  OBSWebSocketHandshakeDetails.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/27/26.
//

import Foundation

extension OBSWebSocket {
    public struct HandshakeDetails: Sendable, Hashable {
        public let eventSubscription: OBSWS.Enums.EventSubscription?
        
        // Received as part of hello message
        public let obsWebSocketVersion: String
        // Received as part of identified message
        public let rpcVersion: Int
        
        internal init(
            eventSubscription: OBSWS.Enums.EventSubscription?,
            obsWebSocketVersion: String,
            rpcVersion: Int
        ) {
            self.eventSubscription = eventSubscription
            self.obsWebSocketVersion = obsWebSocketVersion
            self.rpcVersion = rpcVersion
        }
    }
}
