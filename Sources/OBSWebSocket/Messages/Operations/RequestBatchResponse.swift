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
        
        internal init(
            id: String,
            results: [Response]
        ) {
            self.id = id
            self.results = results
        }
        
        private enum CodingKeys: String, CodingKey {
            case id = "requestId"
            case results
        }
        
        /// Identical to ``OBSOpData/RequestResponse``, except ``id`` is optional.
        public struct Response: OBSOpDataRequestResponse, Sendable, Hashable, Codable {
            public typealias Status = RequestResponse.Status
            
            public static var opCode: OBSWS.Enums.OpCode { RequestBatchResponse.opCode }
            
            public let type: OBSWS.Requests.AllTypes
            public let id: String?
            public let status: Status
            public let data: JSONValue?
            
            internal init(
                type: OBSWS.Requests.AllTypes,
                id: String?,
                status: Status,
                data: JSONValue?
            ) {
                self.type = type
                self.id = id
                self.status = status
                self.data = data
            }
            
            internal init<R: OBSRequest>(
                _ type: R.Type = R.self,
                id: String? = nil,
                status: Status,
                response: R.Response
            ) throws {
                self.type = R.requestType
                self.id = id
                self.status = status
                self.data = try .fromCodable(response)
            }
            
            private enum CodingKeys: String, CodingKey {
                case type = "requestType"
                case id = "requestId"
                case status = "requestStatus"
                case data = "responseData"
            }
        }
    }
}
