//
//  Protocols.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/20/26.
//

import Foundation

/// All types of Requests conform to this.
public protocol OBSRequest: Codable {
    /// The expected type of Response.
    associatedtype Response: OBSRequestResponse
}
/// All types of ``OBSRequest/ResponseType``s conform to this.
public protocol OBSRequestResponse: Codable {}

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
