//
//  OBSRequest.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

/// All types of Requests conform to this.
public protocol OBSRequest: Sendable, Hashable, Codable {
    /// The expected type of Response.
    associatedtype Response: OBSRequestResponse
}
/// All types of ``OBSRequest/Response``s conform to this.
public protocol OBSRequestResponse: Sendable, Hashable, Codable {}

extension OBSWS.Requests {
    public struct EmptyResponse: OBSRequestResponse {}
}
