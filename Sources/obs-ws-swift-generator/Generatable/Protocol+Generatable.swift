//
//  Protocol+Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/18/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftBasicFormat

extension OBSWSProtocol: Generatable {
    private var format: BasicFormat {
        .init(indentationWidth: .spaces(2))
    }
    
    // Using leading newline + trailing newline:
    // For the 1st decl, leading newline moves it to its own line without an extra empty line before
    // For the 2nd decl, it adds to the previous's decl trailing newline, giving an extra empty line between
    
    func generate() throws -> SourceFileSyntax {
        try SourceFileSyntax {
            try EnumDeclSyntax("public enum OBSWS") {
                try EnumDeclSyntax("public enum Enums") {
                    for enumDef in self.enums {
                        try enumDef.generate()
                            .with(\.leadingTrivia, .newline)
                            .with(\.trailingTrivia, .newline)
                    }
                }
                .with(\.leadingTrivia, .newline)
                .with(\.trailingTrivia, .newline)
            }
        }
        .formatted(using: format)
        .as(SourceFileSyntax.self)!
    }
}
