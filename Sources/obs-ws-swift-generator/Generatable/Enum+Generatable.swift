//
//  Enum+Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/17/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension OBSWSProtocol.Enum: Generatable {
    // more generic `DeclSyntax` because an "enum" can also be a struct as an OptionSet
    
    func generate() throws -> DeclSyntax {
        let enumName = self.enumType
            .replacingOccurrences(of: "WebSocket", with: "")
            .replacingOccurrences(of: "Obs", with: "")
            .replacingOccurrences(of: "Ui", with: "UI")
        
        let isOptionSet = self.enumIdentifiers.contains { v in
            guard case .string(let str) = v.enumValue else { return false }
            return str.contains("<")
        }
        let rawValueIsString = self.enumIdentifiers.allSatisfy { enumId -> Bool in
            guard case .string = enumId.enumValue else { return false }
            return true
        }
        
        let typeDef: DeclSyntax
        
        if isOptionSet {
            #warning("TODO: confirm if `raw` or `literal` is the right way to interpolate a string")
            typeDef = try DeclSyntax(
                StructDeclSyntax("public struct \(raw: enumName)") {
                    try VariableDeclSyntax("public let rawValue: Int")
                        .with(\.leadingTrivia, .newline)
                        .with(\.trailingTrivia, .newline)
                    
                    try InitializerDeclSyntax("public init(rawValue: Int)") {
                        CodeBlockItemSyntax("self.rawValue = rawValue")
                    }
                    .with(\.leadingTrivia, .newline)
                    .with(\.trailingTrivia, .newline)
                    
                    for enumCase in self.enumIdentifiers {
                        if let declString = enumCase.syntaxString(forOptionSet: enumName) {
                            try VariableDeclSyntax(declString)
                                .with(
                                    \.leadingTrivia,
                                     .newline
                                        .appending(enumCase.generateDocsTrivia())
                                )
                                .with(\.trailingTrivia, .newline)
                        }
                    }
                }
            )
        } else {
            typeDef = try DeclSyntax(
                EnumDeclSyntax("public enum \(raw: enumName): \(raw: rawValueIsString ? "String" : "Int"), Codable") {
                    try MemberBlockItemListSyntax {
                        for enumCase in self.enumIdentifiers {
                            if let declString = enumCase.syntaxString(forEnum: enumName) {
                                try EnumCaseDeclSyntax(declString)
                                    .with(
                                        \.leadingTrivia,
                                         .newline
                                            .appending(enumCase.generateDocsTrivia())
                                    )
                                    .with(\.trailingTrivia, .newline)
                            }
                        }
                    }
                }
            )
        }
        
        return typeDef
    }
}

extension OBSWSProtocol.Enum.EnumIdentifier {
    fileprivate func syntaxString(
        forOptionSet enumName: String
    ) -> SyntaxNodeString? {
        if case .string(let str) = self.enumValue {
            if str.contains("|") {
                // Example: [.general, .config, .scenes, .inputs, .transitions, .filters, .outputs, .sceneItems, .mediaInputs, .vendors]
                let value = "[." + str
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .split(separator: "|")
                    .map { camelize(String($0)) }
                    .joined(separator: ", .") + "]"
                
                return "public static let \(raw: camelize(self.enumIdentifier)): \(raw: enumName) = \(raw: value)"
            } else {
                let value = str
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                
                return "public static let \(raw: camelize(self.enumIdentifier)) = \(raw: enumName)(rawValue: \(raw: value))"
            }
        } else if case .number(let n) = self.enumValue {
            return "public static let \(raw: camelize(self.enumIdentifier)) = \(raw: Int(n))"
        } else {
            return nil
        }
    }
    
    fileprivate func syntaxString(
        forEnum enumName: String
    ) -> SyntaxNodeString? {
        var identifier = self.enumIdentifier
            .replacingOccurrences(of: "WEBSOCKET_", with: "")
            .replacingOccurrences(of: "OBS_", with: "")
        
        // split by capital letters
        // this is to take out any occurances of any words from the enum name from the enum cases
        #warning("TODO: confirm if i like this")
        // TODO: check out `ObsOutputState`/`OutputState`
        for substring in splitByCapitals(enumName) {
            if let range = identifier.lowercased().range(of: substring.lowercased()) {
                identifier.removeSubrange(range)
                identifier = String(identifier.drop(while: { $0 == "_" }))
            }
        }
        
        if case .string(let str) = self.enumValue {
            let value = Int(str).map { "\($0)" } ?? "\"\(str)\""
            return "case \(raw: camelize(identifier)) = \(raw: value)"
        } else if case .number(let n) = self.enumValue {
            // Number values are always an Int in the spec
            return "case \(raw: camelize(identifier)) = \(raw: Int(n))"
        } else {
            return nil
        }
    }
    
}
