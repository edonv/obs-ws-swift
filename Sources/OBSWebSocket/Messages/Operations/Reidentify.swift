//
//  Reidentify.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

extension OBS.OpData {
    /// Sent at any time after initial identification to update the provided session parameters.
    ///
    /// Only the listed parameters may be changed after initial identification. To change
    /// a parameter not listed, you must reconnect to the `obs-websocket` server.
    /// - term Sent From: Identified client
    /// - term Sent To: `obs-websocket`
    public struct Reidentify: OBSOpDataProtocol {
        public static let opCode: OBS.Enums.OpCode = .reidentify
        
        public let eventSubscriptions: OBS.Enums.EventSubscription?
        
        internal init(eventSubscriptions: OBS.Enums.EventSubscription?) {
            self.eventSubscriptions = eventSubscriptions
        }
    }
}
