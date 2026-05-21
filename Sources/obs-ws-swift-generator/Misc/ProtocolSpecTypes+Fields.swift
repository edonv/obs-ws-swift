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
    
    func fieldType(
        withParent parentTypeName: String
    ) -> String {
        let newType = self.clean(type: self.sharedPart1())
        
        guard newType == "Number" else { return newType }
        
        let shouldBeFloat = valueRestrictions?.contains(".") == true
            || floatProperties.contains(
                fullPropertyPath(withParent: parentTypeName)
            )
        
        return newType.replacingOccurrences(
            of: "Number",
            with: shouldBeFloat ? "Float" : "Int"
        )
    }
    
    func fullPropertyPath(
        withParent parentTypeName: String
    ) -> String {
        [
            propertyPathPrefix(withParent: parentTypeName),
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
