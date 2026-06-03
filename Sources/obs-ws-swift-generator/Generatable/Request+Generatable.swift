//
//  Request+Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/19/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension OBSWSProtocol.Request: Generatable {
    func generate() throws -> StructDeclSyntax {
        return try StructDeclSyntax("public struct \(raw: self.requestType): OBSRequest") {
            if responseFields.isEmpty {
                try TypeAliasDeclSyntax("public typealias Response = EmptyResponse")
                    .prepending(.newline, to: \.leadingTrivia)
                    .with(\.trailingTrivia, .newline)
            }
            
            try VariableDeclSyntax("public static let requestType: OBS.Requests.AllTypes = .\(raw: self.requestType)")
                .with(\.leadingTrivia, .newline)
                .with(\.trailingTrivia, .newline)
            
            // Get fields to write out
            let (normalFields, subtypes) = self.splitFields()
            
            // Write requestFields (ones that aren't sub-properties)
            for reqField in normalFields {
                try reqField.generate()
                    .prepending(.newline, to: \.leadingTrivia)
                    .with(\.trailingTrivia, .newline)
            }
            
            // Explicit public initializer
            let initParamList = FunctionParameterListSyntax {
                for (i, reqField) in normalFields.enumerated() {
                    let addComma = i < normalFields.count - 1
                    FunctionParameterSyntax("\(raw: reqField.valueName): \(raw: reqField.fieldType())\(raw: addComma ? ", ": "")")
                }
            }
            
            try InitializerDeclSyntax.init("public init(\(initParamList))") {
                for reqField in normalFields {
                    CodeBlockItemSyntax("self.\(raw: reqField.valueName) = \(raw: reqField.valueName)")
                        .with(\.trailingTrivia, .newline)
                }
            }
            .prepending(.newline, to: \.leadingTrivia)
            .with(\.trailingTrivia, .newline)
            
            // Write subtypes and their properties
            for (parentFieldName, subtypeFields) in subtypes {
                try StructDeclSyntax("public struct \(raw: parentFieldName): Sendable, Hashable, Codable") {
                    for subtypeField in subtypeFields {
                        try subtypeField.generate()
                            .prepending(.newline, to: \.leadingTrivia)
                            .with(\.trailingTrivia, .newline)
                    }
                }
                .prepending(.newline, to: \.leadingTrivia)
                .with(\.trailingTrivia, .newline)
            }
            
            // Write `Response` type (if there is one)
            if !responseFields.isEmpty {
                try StructDeclSyntax("public struct Response: OBSRequestResponse") {
                    for (i, resField) in responseFields.enumerated() {
                        try resField.generate()
                            .with(\.trailingTrivia, .newlines(i < responseFields.count - 1 ? 2 : 1))
                    }
                }
                .prepending(.newline, to: \.leadingTrivia)
                .with(\.trailingTrivia, .newline)
            }
        }
        .with(\.leadingTrivia, self.generateDocsTrivia())
    }
    
    // MARK: - Helper Functions
    
    private func splitFields() -> (normalFields: [RequestField], subtypes: [String: [RequestField]]) {
        guard !requestFields.isEmpty
                && requestFields.contains(where: { $0.valueName.contains(".") }) else {
            return (requestFields, [:])
        }
        
        /// √ Fields that are not "sub-fields" of properties and that do not have sub-fields
        let normalFields = requestFields
            .compactMap { field -> RequestField? in
                guard !field.valueName.contains(".") else { return nil }
                
                // If field uses a subtype, change valueType to pascalized valueName
                if requestFields.contains(where: {
                    $0.valueName.contains(field.valueName + ".")
                }) {
                    return field.updatingType { _ in
                        pascalize(field.valueName)
                    }
                } else {
                    return field
                }
            }
        
        /// √ Fields whose type will be a custom Object subtype
        let fieldsWithSubtype = normalFields
            .filter { field -> Bool in
                return requestFields.contains {
                    $0.valueName.contains(field.valueName + ".")
                }
            }
        
        /// √ Fields that will make up each of the subtypes for `fieldsWithSubtype`
        let subtypes = requestFields
            .filter { !normalFields.contains($0) }
            .reduce(into: [String: [RequestField]]()) { partialResult, field in
                guard let matchingFieldWithSubtype = fieldsWithSubtype
                    .first(where: { field.valueName.contains($0.valueName + ".") }) else { return }
                
                let subtypeName = pascalize(matchingFieldWithSubtype.valueName)
                partialResult[subtypeName, default: []]
                    .append(field.updatingName { oldName in
                        oldName.replacingOccurrences(of: matchingFieldWithSubtype.valueName + ".", with: "")
                    })
            }
        
        return (
            normalFields,
            subtypes
        )
    }
}
