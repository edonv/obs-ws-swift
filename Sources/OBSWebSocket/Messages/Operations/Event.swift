//
//  Event.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBSOpData {
    /// An event coming from OBS has occured. Eg scene switched, source muted.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: All subscribed and identified clients
    public struct Event: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .event
        
        public let type: String
        
        /// The original intent required to be subscribed to in order to receive the event.
        public let intent: OBSWS.Enums.EventSubscription
        public let data: JSONValue
        
        private enum CodingKeys: String, CodingKey {
            case type = "eventType"
            case intent = "eventIntent"
            case data = "eventData"
        }
    }
}
