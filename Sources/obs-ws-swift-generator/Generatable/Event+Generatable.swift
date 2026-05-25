//
//  Event+Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/21/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension OBSWSProtocol.Event: Generatable {
    func generate() throws -> StructDeclSyntax {
        return try StructDeclSyntax("public struct \(raw: self.eventType): OBSEvent") {
            // - Docs (added at the end outside the builder)
            
            // - Static Properties
            try VariableDeclSyntax("public static let eventType: OBSWS.Events.AllTypes = .\(raw: self.eventType)")
                .with(\.leadingTrivia, .newline)
            try VariableDeclSyntax("public static let eventSubscription: OBSWS.Enums.EventSubscription = .\(raw: camelize(self.eventSubscription))")
                .with(\.leadingTrivia, .newline)
                .with(\.trailingTrivia, .newline)
            
            // - Properties/Fields
            for reqField in self.dataFields {
                try reqField.generate()
                    .prepending(.newline, to: \.leadingTrivia)
                    .with(\.trailingTrivia, .newline)
            }
            
            // - Public init
            let initParamList = FunctionParameterListSyntax {
                for (i, reqField) in dataFields.enumerated() {
                    let addComma = i < dataFields.count - 1
                    FunctionParameterSyntax("\(raw: reqField.valueName): \(raw: reqField.fieldType())\(raw: addComma ? ", ": "")")
                }
            }
            
            try InitializerDeclSyntax("public init(\(initParamList))") {
                for reqField in dataFields {
                    CodeBlockItemSyntax("self.\(raw: reqField.valueName) = \(raw: reqField.valueName)")
                        .with(\.trailingTrivia, .newline)
                }
            }
            .with(\.leadingTrivia, .newline)
            .with(\.trailingTrivia, .newline)
        }
        .with(\.leadingTrivia, self.generateDocsTrivia())
    }
}
