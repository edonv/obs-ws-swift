//
//  OBSEvent.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// All types of Events conform to this.
public protocol OBSEvent: Sendable, Hashable, Codable {}
