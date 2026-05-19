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
