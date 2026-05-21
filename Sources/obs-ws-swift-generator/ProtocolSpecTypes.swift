//
//  ProtocolSpecTypes.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/17/26.
//

import Foundation
import JSONValue

// MARK: - OBSWSProtocol

struct OBSWSProtocol: Codable, Sendable {
    let enums: [Enum]
    let requests: [Request]
    let events: [Event]
}

// MARK: - OBSWSProtocol.Enum

extension OBSWSProtocol {
    struct Enum:  Codable, Sendable {
        let enumType: String
        let enumIdentifiers: [EnumIdentifier]
    
        struct EnumIdentifier: Codable, Sendable {
            let description: String
            let enumIdentifier: String
            let rpcVersion: String
            let deprecated: Bool
            let initialVersion: String
            let enumValue: JSONValue
        }
    }
}

// MARK: - OBSWSProtocol.Request

extension OBSWSProtocol {
    struct Request: Codable, Hashable, Sendable {
        let description: String
        let requestType: String
        let complexity: Int
        let rpcVersion: String
        let deprecated: Bool
        let initialVersion: String
        let category: String
        let requestFields: [RequestField]
        let responseFields: [ResponseField]
        
        struct RequestField: Codable, Hashable, Sendable {
            let valueName: String
            let valueType: String
            let valueDescription: String
            let valueRestrictions: String?
            let valueOptional: Bool
            let valueOptionalBehavior: String?
            
            func updatingName(_ handler: (_ oldName: String) -> String) -> RequestField {
                .init(
                    valueName: handler(valueName),
                    valueType: valueType,
                    valueDescription: valueDescription,
                    valueRestrictions: valueRestrictions,
                    valueOptional: valueOptional,
                    valueOptionalBehavior: valueOptionalBehavior
                )
            }
            
            func updatingType(_ handler: (_ oldType: String) -> String) -> RequestField {
                .init(
                    valueName: valueName,
                    valueType: handler(valueType),
                    valueDescription: valueDescription,
                    valueRestrictions: valueRestrictions,
                    valueOptional: valueOptional,
                    valueOptionalBehavior: valueOptionalBehavior
                )
            }
        }
        
        struct ResponseField: Codable, Hashable, Sendable {
            let valueName: String
            let valueType: String
            let valueDescription: String
        }
    }
}

// MARK: - OBSWSProtocol.Event

extension OBSWSProtocol {
    struct Event: Codable, Sendable {
        let description: String
        let eventType: String
        let eventSubscription: String
        let complexity: Int
        let rpcVersion: String
        let deprecated: Bool
        let initialVersion: String
        let category: String
        let dataFields: [Field]
        
        struct Field: Codable, Sendable {
            let valueName: String
            let valueType: String
            let valueDescription: String
        }
    }
}
