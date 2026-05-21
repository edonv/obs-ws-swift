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
    
    func generate() throws -> DeclSyntax {
        try EnumDeclSyntax("public enum OBSWS") {
            try EnumDeclSyntax("public enum Enums") {
                for enumDef in self.enums {
                    try enumDef.generate()
                        .with(\.leadingTrivia, .newline)
                        .with(\.trailingTrivia, .newline)
                }
            }
            .with(\.trailingTrivia, .newline)
        }
        .formatted(using: format).as(DeclSyntax.self)!
    }
}
