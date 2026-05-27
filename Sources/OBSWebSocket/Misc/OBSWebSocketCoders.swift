//
//  OBSWebSocketCoders.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation
import MessagePacker

// MARK: - Protocols

protocol OBSWSEncoder: Sendable, Copyable {
//    init()
    
    func encode<T: Encodable>(_ value: T) throws -> Data
}

struct AnyOBSWSEncoder: OBSWSEncoder {
    let encodeCallback: @Sendable (Encodable) throws -> Data
    
    init(encode: @Sendable @escaping (Encodable) throws -> Data) {
        self.encodeCallback = encode
    }
    
    func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try encodeCallback(value)
    }
}

protocol OBSWSDecoder: Sendable, Copyable {
//    init()
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T
}

struct AnyOBSWSDecoder: OBSWSDecoder {
    let decodeCallback: @Sendable (Decodable.Type, Data) throws -> Decodable
    
    init(decode: @Sendable @escaping (Decodable.Type, Data) throws -> Decodable) {
        self.decodeCallback = decode
    }
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        try decodeCallback(type, data) as! T
    }
}

protocol CoderPair {
    associatedtype Encoder: OBSWSEncoder
    associatedtype Decoder: OBSWSDecoder
    
    var encoder: Encoder { get }
    var decoder: Decoder { get }
}

extension CoderPair {
    func toAny() -> AnyCoderPair {
        .init(encoder: self.encoder, decoder: self.decoder)
    }
}

struct AnyCoderPair: CoderPair {
    let encoder: AnyOBSWSEncoder
    let decoder: AnyOBSWSDecoder
    
    init<E: OBSWSEncoder, D: OBSWSDecoder>(encoder: E, decoder: D) {
        self.encoder = .init { encodable in
            try encoder.encode(encodable)
        }
        self.decoder = .init { decodable, data in
            try decoder.decode(decodable, from: data)
        }
    }
}

// MARK: - JSON

extension JSONEncoder: OBSWSEncoder {}
extension JSONDecoder: OBSWSDecoder {}

internal struct JSONCoders: CoderPair {
    let encoder: JSONEncoder = .init()
    let decoder: JSONDecoder = .init()
}

// MARK: - MessagePack

extension MessagePackEncoder: OBSWSEncoder {}
extension MessagePackDecoder: OBSWSDecoder {}

internal struct MessagePackCoders: CoderPair {
    let encoder: MessagePackEncoder = .init()
    let decoder: MessagePackDecoder = .init()
}

extension AnyCoderPair {
    static func pair(for mode: OBSWebSocket.ConnectionDetails.MessageEncoding?) -> Self {
        mode == .msgPack
        ? .msgPack
        : .json
    }
    static var json: Self { JSONCoders().toAny() }
    static var msgPack: Self { MessagePackCoders().toAny() }
}
