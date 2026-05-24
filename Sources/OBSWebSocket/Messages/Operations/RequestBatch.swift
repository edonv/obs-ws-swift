//
//  RequestBatch.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBSOpData {
    /// Client is making a batch of requests for `obs-websocket`.
    ///
    /// Requests are processed serially (in order) by the server
    ///
    /// - term Sent From: Identified client
    /// - term Sent To: `obs-websocket`
    public struct RequestBatch: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .requestBatch
        
        public let id: String
        
        /// When `haltOnFailure` is `true`, the processing of requests will be halted on first failure.
        ///
        /// Returns only the processed requests in ``OBSOpData/RequestBatchResponse``.
        ///
        /// Defaults to `false`.
        public let haltOnFailure: Bool?
        
        /// Defaults to ``OBSWS/Enums/RequestBatchExecutionType/serialRealtime``.
        public let executionType: OBSWS.Enums.RequestBatchExecutionType?
        
        /// Requests in the `requests` array follow the same structure as the ``Request`` payload data format, however ``Request/id`` is an optional field.
        public let requests: [Request]
        
        private enum CodingKeys: String, CodingKey {
            case id = "requestId"
            case haltOnFailure
            case executionType
            case requests
        }
        
        /// Identical to ``OBSOpData/Request``, except ``id`` is optional.
        public struct Request: Sendable, Hashable, Codable {
            public let type: OBSWS.Requests.AllTypes
            public let id: String?
            public let data: JSONValue?
            
            private enum CodingKeys: String, CodingKey {
                case type = "requestType"
                case id = "requestId"
                case data = "requestData"
            }
        }
    }
}
