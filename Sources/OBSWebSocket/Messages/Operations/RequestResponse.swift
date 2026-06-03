//
//  RequestResponse.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBS.OpData {
    /// `obs-websocket` is responding to a request coming from a client.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Identified client which made the request
    public struct RequestResponse: OBSOpDataProtocol, OBSOpDataRequestResponse {
        public static let opCode: OBS.Enums.OpCode = .requestResponse
        
        public let type: OBS.Requests.AllTypes
        public let id: String
        public let status: Status
        public let data: JSONValue?
        
        internal init(
            type: OBS.Requests.AllTypes,
            id: String,
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
            id: String,
            status: Status,
            response: R.Response
        ) throws {
            self.type = R.requestType
            self.id = id
            self.status = status
            self.data = try .fromCodable(response)
        }
        
        public struct Status: Sendable, Hashable, Codable {
            /// `result` is `true` if the request resulted in ``OBS/Enums/RequestStatus/success`` (100).
            /// `false` if otherwise.
            public let result: Bool
            
            public let code: OBS.Enums.RequestStatus
            
            /// May be provided by the server on errors to offer further details on why a request failed.
            public let comment: String?
            
            internal init(
                result: Bool,
                code: OBS.Enums.RequestStatus,
                comment: String?
            ) {
                self.result = result
                self.code = code
                self.comment = comment
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case type = "requestType"
            case id = "requestId"
            case status = "requestStatus"
            case data = "responseData"
        }
    }
}
