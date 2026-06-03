//
//  OBSMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

/// A type used for sending and receiving information to and from OBS.
public struct OBSMessage<Body: OBSOpDataProtocol>: OBSMessageProtocol {
    public typealias OpCode = OBSWS.Enums.OpCode
    
    public let operation: OpCode
    public let data: Body
    
    public init(
        operation: OpCode,
        data: Body
    ) {
        self.operation = operation
        self.data = data
    }
    
    public init(data: Body) {
        self.operation = Body.opCode
        self.data = data
    }
    
    func untyped() throws -> OBSUntypedMessage {
        .init(
            operation: operation,
            data: try JSONValue.fromCodable(data)
        )
    }
}

/// Namespace for type aliases of typed ``OBSMessage``s.
public enum OBSMessages {
    public typealias Hello = OBSMessage<OBS.OpData.Hello>
    public typealias Identify = OBSMessage<OBS.OpData.Identify>
    public typealias Identified = OBSMessage<OBS.OpData.Identified>
    public typealias Reidentify = OBSMessage<OBS.OpData.Reidentify>
    public typealias Event = OBSMessage<OBS.OpData.Event>
    public typealias Request = OBSMessage<OBS.OpData.Request>
    public typealias RequestResponse = OBSMessage<OBS.OpData.RequestResponse>
    public typealias RequestBatch = OBSMessage<OBS.OpData.RequestBatch>
    public typealias RequestBatchResponse = OBSMessage<OBS.OpData.RequestBatchResponse>
}
