//
//  OBS.UntypedMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

extension OBS {
    /// A general type used for easier receipt of messages without having to cast immediately.
    public struct UntypedMessage: OBSMessageProtocol {
        public typealias OpCode = OBSWS.Enums.OpCode
        
        public let operation: OpCode
        
        /// The body of the message.
        ///
        /// Its structure varies based on the type of message (``OBS/UntypedMessage/operation``).
        public let data: JSONValue
        
        public init(
            operation: OpCode,
            data: JSONValue
        ) {
            self.operation = operation
            self.data = data
        }
        
        /// Attempts to cast the message to a ``OBS/Message`` with a typed ``OBS/Message/data`` property.
        ///
        /// It tries to do this based on the value of the ``operation`` property. It fails immediately if ``operation`` doesn't match ``OBSOpDataProtocol/opCode`` of the specified `type`.
        /// - Parameter type: <#type description#>
        /// - Throws: An ``Error`` if unable to cast successfully.
        /// - Returns: A typed `OBS.Message`.
        public func `as`<T: OBSOpDataProtocol>(_ type: T.Type = T.self) throws(Error) -> OBS.Message<T> {
            try .init(operation: type.opCode, data: messageData())
        }
        
        private func messageData<T: OBSOpDataProtocol>(_ type: T.Type = T.self) throws(Error) -> T {
            guard type.opCode == operation else {
                throw .opCodeDoesNotMatchCastingType(messageCode: operation, expectedCode: type.opCode)
            }
            
            do {
                switch operation {
                case .hello where T.self is OBS.OpData.Hello.Type:
                    return try data.toCodable(OBS.OpData.Hello.self) as! T
                case .identify where T.self is OBS.OpData.Identify.Type:
                    return try data.toCodable(OBS.OpData.Identify.self) as! T
                case .identified where T.self is OBS.OpData.Identified.Type:
                    return try data.toCodable(OBS.OpData.Identified.self) as! T
                case .reidentify where T.self is OBS.OpData.Reidentify.Type:
                    return try data.toCodable(OBS.OpData.Reidentify.self) as! T
                case .event where T.self is OBS.OpData.Event.Type:
                    return try data.toCodable(OBS.OpData.Event.self) as! T
                case .request where T.self is OBS.OpData.Request.Type:
                    return try data.toCodable(OBS.OpData.Request.self) as! T
                case .requestResponse where T.self is OBS.OpData.RequestResponse.Type:
                    return try data.toCodable(OBS.OpData.RequestResponse.self) as! T
                case .requestBatch where T.self is OBS.OpData.RequestBatch.Type:
                    return try data.toCodable(OBS.OpData.RequestBatch.self) as! T
                case .requestBatchResponse where T.self is OBS.OpData.RequestBatchResponse.Type:
                    return try data.toCodable(OBS.OpData.RequestBatchResponse.self) as! T
                    
                default:
                    throw Error.dataDoesNotMatchExpectedType(data: data, code: operation)
                }
            } catch let error as Error {
                throw error
            } catch {
                throw Error.dataDoesNotMatchExpectedType(data: data, code: operation)
            }
        }
        
        /// Errors pertaining to ``OBS/UntypedMessage``.
        public enum Error: Swift.Error {
            /// Thrown when trying to type-cast an untyped message and ``OBS/UntypedMessage/operation`` does not match the provided type's ``OBSOpDataProtocol/opCode``.
            case opCodeDoesNotMatchCastingType(messageCode: OpCode, expectedCode: OpCode)
            
            /// Thrown when trying to type-cast an untyped message and the contained ``OBS/UntypedMessage/data`` is not the expected type (specified by ``OBS/UntypedMessage/operation``).
            case dataDoesNotMatchExpectedType(data: JSONValue?, code: OpCode)
        }
    }
}
