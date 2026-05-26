//
//  Request.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBSOpData {
    /// Client is making a request to `obs-websocket`.
    ///
    /// e.g. get current scene, create source.
    ///
    /// - term Sent From: Identified client
    /// - term Sent To: `obs-websocket`
    public struct Request: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .request
        
        public let type: OBSWS.Requests.AllTypes
        public let id: String
        public let data: JSONValue?
        
        private enum CodingKeys: String, CodingKey {
            case type = "requestType"
            case id = "requestId"
            case data = "requestData"
        }
        
        internal init(
            type: OBSWS.Requests.AllTypes,
            id: String,
            data: JSONValue?
        ) {
            self.type = type
            self.id = id
            self.data = data
        }
        
        internal init<R: OBSRequest>(
            _ request: R,
            id: String
        ) throws {
            self.type = R.requestType
            self.id = id
            self.data = try .fromCodable(request)
        }
    }
}
