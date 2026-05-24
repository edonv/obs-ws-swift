//
//  Protocols.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/20/26.
//

import Foundation

/// All types of Enums conform to this.
public protocol OBSEnum: Sendable, Hashable, Codable {}

/// All types of Requests conform to this.
public protocol OBSRequest: Sendable, Hashable, Codable {
    /// The expected type of Response.
    associatedtype Response: OBSRequestResponse
}
/// All types of ``OBSRequest/ResponseType``s conform to this.
public protocol OBSRequestResponse: Sendable, Hashable, Codable {}

extension OBSWS.Requests {
    public struct EmptyResponse: OBSRequestResponse {}
}

extension OBSRequest {
    /// Self's metatype as a string.
    static var typeName: String {
        String(describing: self)
            .replacingOccurrences(of: #"\(.*\)"#, with: "", options: .regularExpression)
    }
}

/// All types of Events conform to this.
public protocol OBSEvent: Codable {}

public extension OBSEvent {
    /// Self's metatype as a string.
    static var typeName: String {
        String(describing: self)
            .replacingOccurrences(of: #"\(.*\)"#, with: "", options: .regularExpression)
    }
}
