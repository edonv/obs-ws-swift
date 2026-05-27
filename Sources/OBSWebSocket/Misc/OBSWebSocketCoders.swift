//
//  OBSWebSocketCoders.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation
import MessagePacker

// MARK: - Protocols

protocol OBSWebSocketEncoder: Sendable, Copyable {
    init()
    
    func encode<T: Encodable>(_ value: T) throws -> Data
}

protocol OBSWebSocketDecoder: Sendable, Copyable {
    init()
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T
}

// MARK: - JSON

extension JSONEncoder: OBSWebSocketEncoder {}
extension JSONDecoder: OBSWebSocketDecoder {}

// MARK: - MessagePack

extension MessagePackEncoder: OBSWebSocketEncoder {}
extension MessagePackDecoder: OBSWebSocketDecoder {}
