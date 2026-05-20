//
//  Excludable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/20/26.
//

import Foundation

/// A Wrapper type that describes that an item can be excluded when encoded/decoded. This is important
/// in JSON contexts where a property being optional (missing entirely) might specifically matter, as
/// opposed to it being `null`.
@propertyWrapper
public struct Excludable<T: Codable> {
    public enum Value {
        case included(T)
        case null
        case excluded
    }
    
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Excludable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.wrappedValue {
        case .included(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .excluded:
            return
        }
    }
}

extension Excludable: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(T.self) {
            self.init(.included(value))
        } else if container.decodeNil() {
            self.init(.null)
        } else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Value is not of \(T.self) type."))
        }
    }
}
