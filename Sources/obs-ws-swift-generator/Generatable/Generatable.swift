//
//  Generatable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/17/26.
//

import Foundation
import SwiftSyntax
import SwiftBasicFormat

protocol Generatable {
    associatedtype DeclType: DeclSyntaxProtocol
    func generate() throws -> DeclType
}
