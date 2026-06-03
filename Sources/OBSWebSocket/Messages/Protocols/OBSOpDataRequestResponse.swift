//
//  OBSOpDataRequestResponse.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 6/3/26.
//

import Foundation
import JSONValue

public protocol OBSOpDataRequestResponse: Sendable, Hashable {
    associatedtype ID: Sendable, Hashable
    
    static var opCode: OBS.Enums.OpCode { get }
    
    var type: OBS.Requests.AllTypes { get }
    var id: ID { get }
    var status: OBS.OpData.RequestResponse.Status { get }
    var data: JSONValue? { get }
}

extension OBSOpDataRequestResponse {
    internal func asResponse<R: OBSRequest>(ofType type: R.Type = R.self) throws -> R.Response {
        let d: JSONValue
        
        if R.Response.self != OBS.Requests.EmptyResponse.self
            && data == nil {
            throw OBS.UntypedMessage.Error.dataDoesNotMatchExpectedType(data: data, code: Self.opCode)
        } else {
            d = data ?? .object([:])
        }
        
        return try d.toCodable(R.Response.self)
    }
}
