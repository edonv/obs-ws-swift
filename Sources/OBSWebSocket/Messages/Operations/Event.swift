//
//  Event.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBS.OpData {
    /// An event coming from OBS has occured. Eg scene switched, source muted.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: All subscribed and identified clients
    public struct Event: OBSOpDataProtocol {
        public static let opCode: OBS.Enums.OpCode = .event
        
        public let type: OBS.Events.AllTypes
        /// The original intent required to be subscribed to in order to receive the event.
        public let intent: OBS.Enums.EventSubscription
        public let data: JSONValue
        
        internal init(
            type: OBS.Events.AllTypes,
            intent: OBS.Enums.EventSubscription,
            data: JSONValue
        ) {
            self.type = type
            self.intent = intent
            self.data = data
        }
        
        internal init<E: OBSEvent>(
            _ event: E
        ) throws {
            self.type = E.eventType
            self.intent = E.eventSubscription
            self.data = try .fromCodable(event)
        }
        
        private enum CodingKeys: String, CodingKey {
            case type = "eventType"
            case intent = "eventIntent"
            case data = "eventData"
        }
        
        public func asEvent<E: OBSEvent>(ofType type: E.Type) throws -> E {
            guard self.type == E.eventType else {
                throw OBS.UntypedMessage.Error
                    .dataDoesNotMatchExpectedType(data: data, code: Event.opCode)
            }
            
            return try data.toCodable(E.self)
        }
    }
}
