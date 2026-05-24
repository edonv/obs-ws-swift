//
//  RequestBatchResponse.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBSOpData {
    /// `obs-websocket` is responding to a request batch coming from the client.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Identified client which made the request
    public struct RequestBatchResponse: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .requestBatchResponse
        
        public let id: String
        public let results: [Response]
        
        private enum CodingKeys: String, CodingKey {
            case id = "requestId"
            case results
        }
        
        /// Identical to ``OBSOpData/RequestResponse``, except ``id`` is optional.
        public struct Response: Sendable, Hashable, Codable {
            public let type: OBSWS.Requests.AllTypes
            public let id: String?
            public let status: RequestResponse.Status
            public let data: JSONValue?
            
            private enum CodingKeys: String, CodingKey {
                case type = "requestType"
                case id = "requestId"
                case status = "requestStatus"
                case data = "responseData"
            }
        }
    }
}
