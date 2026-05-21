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
        return try .init("public struct \(raw: self.requestType): OBSRequest") {
            if responseFields.isEmpty {
                try TypeAliasDeclSyntax("public typealias Response = EmptyResponse")
                    .with(\.trailingTrivia, .newlines(2))
            }
            
            // Get fields to write out
            let (normalFields, subtypes) = self.splitFields()
            
            // Write requestFields (ones that aren't sub-properties)
            for (i, reqField) in normalFields.enumerated() {
                try reqField.generate()
                    .with(\.trailingTrivia, .newlines(i < normalFields.count - 1 ? 2 : 0))
            }
            
            // Explicit public initializer
            let initParamList = FunctionParameterListSyntax {
                for (i, reqField) in normalFields.enumerated() {
                    let addComma = i < normalFields.count - 1
                    FunctionParameterSyntax("\(raw: reqField.valueName): \(raw: reqField.fieldType)\(raw: addComma ? ", ": "")")
                }
            }
            
            try InitializerDeclSyntax.init("public init(\(initParamList))") {
                for reqField in normalFields {
                    CodeBlockItemSyntax("self.\(raw: reqField.valueName) = \(raw: reqField.valueName)")
                        .with(\.trailingTrivia, .newline)
                }
            }
            .with(\.leadingTrivia, .newlines(normalFields.isEmpty /*&& responseFields.isEmpty*/ ? 1 : 2))
            
            // Write subtypes and their properties
            for (i, (parentFieldName, subtypeFields)) in subtypes.enumerated() {
                try StructDeclSyntax("public struct \(raw: parentFieldName): Hashable, Codable") {
                    for (j, subtypeField) in subtypeFields.enumerated() {
                        try subtypeField.generate()
                            .with(\.trailingTrivia, .newlines(j < subtypeFields.count - 1 ? 2 : 0))
                    }
                }
                .with(\.leadingTrivia, .newlines(i < subtypes.count - 1 ? 2 : 1))
                .with(\.trailingTrivia, .newlines(responseFields.isEmpty ? 1 : 0))
            }
            
            // Write `Response` type (if there is one)
            if !responseFields.isEmpty {
                try StructDeclSyntax("public struct Response: OBSRequestResponse") {
                    for (i, resField) in responseFields.enumerated() {
                        try resField.generate()
                            .with(\.trailingTrivia, .newlines(i < responseFields.count - 1 ? 2 : 1))
                    }
                }
                .with(\.leadingTrivia, .newlines(2))
            }
        }.with(\.leadingTrivia, self.generateDocsTrivia())
    }
    
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
