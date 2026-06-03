//
//  OBSEvent.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// All types of Events conform to this.
public protocol OBSEvent: Sendable, Hashable, Codable {
    /// Enum representation of its own ``OBSEvent`` type.
    static var eventType: OBS.Events.AllTypes { get }
    
    /// Required ``OBS/Enums/EventSubscription`` to receive this event.
    static var eventSubscription: OBS.Enums.EventSubscription { get }
}
