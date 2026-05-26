//
//  OBSUntypedMessage.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import JSONValue

/// A general type used for easier receipt of messages without having to cast immediately.
public struct OBSUntypedMessage: OBSMessageProtocol {
    public typealias OpCode = OBSWS.Enums.OpCode
    
    public let operation: OpCode
    
    /// The body of the message.
    ///
    /// Its structure varies based on the type of message (``OBSUntypedMessage/operation``).
    public let data: JSONValue
    
    public init(
        operation: OpCode,
        data: JSONValue
    ) {
        self.operation = operation
        self.data = data
    }
    
    /// Attempts to cast the message to a ``OBSMessage`` with a typed ``OBSMessage/data`` property.
    /// 
    /// It tries to do this based on the value of the ``operation`` property. It fails immediately if ``operation`` doesn't match ``OBSOpDataProtocol/opCode`` of the specified `type`.
    /// - Parameter type: <#type description#>
    /// - Throws: ``Error/unableToCastBody(operation:)`` if unable to cast successfully.
    /// - Returns: A typed `OBSMessage`.
    public func `as`<T: OBSOpDataProtocol>(_ type: T.Type = T.self) throws(Error) -> OBSMessage<T> {
        try .init(operation: type.opCode, data: messageData())
    }
    
    private func messageData<T: OBSOpDataProtocol>(_ type: T.Type = T.self) throws(Error) -> T {
        guard type.opCode == operation else {
            throw .opCodeDoesNotMatchCastingType(messageCode: operation, expectedCode: type.opCode)
        }
        
        do {
            switch operation {
            case .hello where T.self is OBSOpData.Hello.Type:
                return try data.toCodable(OBSOpData.Hello.self) as! T
            case .identify where T.self is OBSOpData.Identify.Type:
                return try data.toCodable(OBSOpData.Identify.self) as! T
            case .identified where T.self is OBSOpData.Identified.Type:
                return try data.toCodable(OBSOpData.Identified.self) as! T
            case .reidentify where T.self is OBSOpData.Reidentify.Type:
                return try data.toCodable(OBSOpData.Reidentify.self) as! T
            case .event where T.self is OBSOpData.Event.Type:
                return try data.toCodable(OBSOpData.Event.self) as! T
            case .request where T.self is OBSOpData.Request.Type:
                return try data.toCodable(OBSOpData.Request.self) as! T
            case .requestResponse where T.self is OBSOpData.RequestResponse.Type:
                return try data.toCodable(OBSOpData.RequestResponse.self) as! T
            case .requestBatch where T.self is OBSOpData.RequestBatch.Type:
                return try data.toCodable(OBSOpData.RequestBatch.self) as! T
            case .requestBatchResponse where T.self is OBSOpData.RequestBatchResponse.Type:
                return try data.toCodable(OBSOpData.RequestBatchResponse.self) as! T
                
            default:
                throw Error.dataDoesNotMatchExpectedType(data: data, code: operation)
            }
        } catch let error as Error {
            throw error
        } catch {
            throw Error.dataDoesNotMatchExpectedType(data: data, code: operation)
        }
    }
    
    /// Errors pertaining to ``OBSUntypedMessage``.
    public enum Error: Swift.Error {
        /// Thrown when trying to type-cast an untyped message and ``OBSUntypedMessage/operation`` does not match the provided type's ``OBSOpDataProtocol/opCode``.
        case opCodeDoesNotMatchCastingType(messageCode: OpCode, expectedCode: OpCode)
        
        /// Thrown when trying to type-cast an untyped message and the contained ``OBSUntypedMessage/data`` is not the expected type (specified by ``OBSUntypedMessage/operation``).
        case dataDoesNotMatchExpectedType(data: JSONValue, code: OpCode)
    }
}
