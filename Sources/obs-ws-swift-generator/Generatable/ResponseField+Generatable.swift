//
//  ResponseField+Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/21/26.
//

import Foundation
import SwiftSyntax

extension OBSWSProtocol.Request.ResponseField: Generatable {
    func generate() throws -> VariableDeclSyntax {
        try VariableDeclSyntax("public let \(raw: self.valueName): \(raw: self.fieldType())")
            .with(\.leadingTrivia, self.generateDocsTrivia())
    }
}
