//
//  OBSOpDataRequestResponse.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 6/3/26.
//

import Foundation
import JSONValue

public protocol OBSOpDataRequestResponse: Sendable, Hashable {
    static var opCode: OBSWS.Enums.OpCode { get }
    
    var type: OBSWS.Requests.AllTypes { get }
    var status: OBSOpData.RequestResponse.Status { get }
    var data: JSONValue? { get }
}

extension OBSOpDataRequestResponse {
    internal func asResponse<R: OBSRequest>(ofType type: R.Type = R.self) throws -> R.Response {
        let d: JSONValue
        
        if R.Response.self != OBSWS.Requests.EmptyResponse.self
            && data == nil {
            throw OBSUntypedMessage.Error.dataDoesNotMatchExpectedType(data: data, code: Self.opCode)
        } else {
            d = data ?? .object([:])
        }
        
        return try d.toCodable(R.Response.self)
    }
}
