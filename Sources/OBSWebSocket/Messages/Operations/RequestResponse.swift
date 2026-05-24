//
//  RequestResponse.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBSOpData {
    /// `obs-websocket` is responding to a request coming from a client.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Identified client which made the request
    public struct RequestResponse: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .requestResponse
        
        public let type: OBSWS.Requests.AllTypes
        public let id: String
        public let status: Status
        public let data: JSONValue?
        
        public struct Status: Sendable, Hashable, Codable {
            /// `result` is `true` if the request resulted in ``OBSWS/Enums/RequestStatus/success`` (100).
            /// `false` if otherwise.
            public let result: Bool
            
            public let code: OBSWS.Enums.RequestStatus
            
            /// May be provided by the server on errors to offer further details on why a request failed.
            public let comment: String?
        }
        
        private enum CodingKeys: String, CodingKey {
            case type = "requestType"
            case id = "requestId"
            case status = "requestStatus"
            case data = "responseData"
        }
    }
}
