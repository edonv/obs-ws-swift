//
//  ProtocolSpecTypes+Fields.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/21/26.
//

import Foundation

protocol FieldType {
    // Properties both normally have
    var valueName: String { get }
    var valueType: String { get }
    var valueDescription: String { get }
    
    // Properties only 1 has
    var valueRestrictions: String? { get }
    
    func propertyPathPrefix(withParent parentTypeName: String) -> String
    func clean(type: String) -> String
}

extension FieldType {
    private func sharedPart1() -> String {
        return valueType
            .replacingOccurrences(of: "Object", with: "JSONValue")
            .replacingOccurrences(of: "Any", with: "JSONValue")
            .replacingOccurrences(of: "Boolean", with: "Bool")
            .replacingOccurrences(
                of: #"Array\<"#,
                with: "[",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: #"\>$"#,
                with: "]",
                options: .regularExpression
            )
        
        // TODO: implement logic for `Excludable` and
        // If valueOptional is false && valueDescription contains "null", add a `?` to the type
        // || if valueOptional is true && valueDescription doesn't contain "null", add a `?` to the type
//        if (!field.valueOptional && field.valueDescription.contains("null"))
//            || (field.valueOptional && !field.valueDescription.contains("null")) {
//            valueType += "?"
//        } else if field.valueOptional && field.valueDescription.contains("null") {
//            // If valueOptional is true && valueDescription contains "null", make the type `Excludable<\(valueType)>`
//            valueType = "Excludable<\(valueType)>"
//            optionalTerm = "Excluded"
//        }
        
        // TODO: difference between "omit" (optional) and "nil" (null)?
    }
    
    func fieldType() -> String {
        let newType = self.clean(type: self.sharedPart1())
        
        // TODO: implement `getExplicitType()` and `explicitTypes`
        
        if newType.contains("Number") {
            let shouldBeFloat = valueRestrictions?.contains(".") == true
            || floatProperties.contains(
                fullPropertyPath()
            )
            
            return newType.replacingOccurrences(
                of: "Number",
                with: shouldBeFloat ? "Float" : "Int"
            )
        } else if newType.contains("String") {
            // If it's a String-based enum type
            if let range = valueDescription.range(of: #"(`\w+`) enum"#, options: .regularExpression) {
                let substring = String(valueDescription[range])
                    .replacingOccurrences(of: "`", with: "")
                    .replacingOccurrences(of: " enum", with: "")
                    .replacingOccurrences(of: "Obs", with: "")
                return "OBS.Enums." + substring
            }
            
            // If it's a UUID
            if valueName.lowercased().contains("uuid") {
                return "UUID"
            }
        }
        
        return newType
    }
    
    func fullPropertyPath() -> String {
        [
            propertyPathPrefix(withParent: String(reflecting: Self.self)),
            valueName,
        ].joined(separator: ".")
    }
}

/// Properties that should be Floats instead of Ints, but don't have example in docs.
private let floatProperties: [String] = [
    "GetStats.Response.availableDiskSpace",
    "GetStats.Response.cpuUsage",
    "GetStats.Response.averageFrameRenderTime",
    "GetStats.Response.memoryUsage",
    "GetStats.Response.activeFps",
]

extension OBSWSProtocol.Request.RequestField: FieldType {
    func propertyPathPrefix(withParent parentTypeName: String) -> String {
        "\(parentTypeName).Request"
    }
    
    func clean(type: String) -> String {
        guard self.valueOptional else { return type }
        return type + "?"
    }
}

extension OBSWSProtocol.Request.ResponseField: FieldType {
    var valueRestrictions: String? { nil }
    
    func propertyPathPrefix(withParent parentTypeName: String) -> String {
        "\(parentTypeName).Response"
    }
    
    func clean(type: String) -> String { type }
}

extension OBSWSProtocol.Event.Field: FieldType {
    var valueRestrictions: String? { nil }
    
    func propertyPathPrefix(withParent parentTypeName: String) -> String {
        "\(parentTypeName)"
    }
    
    func clean(type: String) -> String { type }
}
