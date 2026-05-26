//
//  Reidentify.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

extension OBSOpData {
    /// Sent at any time after initial identification to update the provided session parameters.
    ///
    /// Only the listed parameters may be changed after initial identification. To change
    /// a parameter not listed, you must reconnect to the `obs-websocket` server.
    /// - term Sent From: Identified client
    /// - term Sent To: `obs-websocket`
    public struct Reidentify: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .reidentify
        
        public let eventSubscriptions: OBSWS.Enums.EventSubscription?
        
        internal init(eventSubscriptions: OBSWS.Enums.EventSubscription?) {
            self.eventSubscriptions = eventSubscriptions
        }
    }
}
