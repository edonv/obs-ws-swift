//
//  OBSMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBS {
    /// A type used for sending and receiving information to and from OBS.
    public struct Message<Body: OBSOpDataProtocol>: OBSMessageProtocol {
        public typealias OpCode = OBS.Enums.OpCode
        
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
        
        func untyped() throws -> OBS.UntypedMessage {
            .init(
                operation: operation,
                data: try JSONValue.fromCodable(data)
            )
        }
    }
    
    /// Namespace for type aliases of typed ``OBS/Message``s.
    public enum Messages {
        public typealias Hello = OBS.Message<OBS.OpData.Hello>
        public typealias Identify = OBS.Message<OBS.OpData.Identify>
        public typealias Identified = OBS.Message<OBS.OpData.Identified>
        public typealias Reidentify = OBS.Message<OBS.OpData.Reidentify>
        public typealias Event = OBS.Message<OBS.OpData.Event>
        public typealias Request = OBS.Message<OBS.OpData.Request>
        public typealias RequestResponse = OBS.Message<OBS.OpData.RequestResponse>
        public typealias RequestBatch = OBS.Message<OBS.OpData.RequestBatch>
        public typealias RequestBatchResponse = OBS.Message<OBS.OpData.RequestBatchResponse>
    }
}
