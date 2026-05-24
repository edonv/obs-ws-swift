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
        
        public let type: String
        public let id: String
        public let data: JSONValue?
        
        private enum CodingKeys: String, CodingKey {
            case type = "requestType"
            case id = "requestId"
            case data = "requestData"
        }
    }
}
