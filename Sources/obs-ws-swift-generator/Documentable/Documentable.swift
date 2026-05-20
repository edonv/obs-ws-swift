//
//  Describable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/19/26.
//

import Foundation
import SwiftSyntax

/// An OBS-WS protocol type (the types that make up the protocol JSON, not the generated types) that can have documentation comments generated for it in a standardized format.
protocol Documentable {
    var documentation: Documentation { get }
}

extension Documentable {
    func generateDocsTrivia() -> Trivia {
        self.documentation.generateDocsTrivia()
    }
}

struct Documentation {
    let description: String
    let eventSubscription: String?
    let category: String?
    let complexity: Int?
    let rpcVersion: String?
    let deprecated: Bool?
    let initialVersion: String?
    let valueRestrictions: String?
    let valueOptionalBehavior: String?
    
    init(
        description: String,
        eventSubscription: String? = nil,
        category: String? = nil,
        complexity: Int? = nil,
        rpcVersion: String? = nil,
        deprecated: Bool? = nil,
        initialVersion: String? = nil,
        valueRestrictions: String? = nil,
        valueOptionalBehavior: String? = nil
    ) {
        self.description = description
        self.eventSubscription = eventSubscription
        self.category = category
        self.complexity = complexity
        self.rpcVersion = rpcVersion
        self.deprecated = deprecated
        self.initialVersion = initialVersion
        self.valueRestrictions = valueRestrictions
        self.valueOptionalBehavior = valueOptionalBehavior
    }
    
    func generateDocsTrivia(
        // TODO: enumName??
    ) -> Trivia {
        #warning("TODO: Refactor first line to work like original code `findReplaceLinkedSymbolsInDescs`")
        //        findReplaceLinkedSymbolsInDescs(
        //            enumCase.description
        //                .replacingOccurrences(of: "Note:", with: "- Note:"),
        //            category: .enums,
        //            symbolPath: [
        //                enumName,
        //                camelized(c.enumIdentifier)
        //            ]
        //        )
        
        let descPieces: [TriviaPiece] = description
            .replacingOccurrences(
                of: "Note:",
                with: "- Note:",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: "null",
                with: "nil"
            )
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { .docLineComment("/// " + $0) }
        
        
        return Trivia(pieces: (
            descPieces + [
                // /// > Event Subscription: ``OBSWS/Enums/EventSusbcription/general``
                self.category
                    .map { .docLineComment("/// > Event Subscription: ``OBSWS/Enums/EventSusbcription/\(camelize($0))``") },
                // /// > Category: ``General``
                self.category
                    .map { .docLineComment("/// > Category: ``\($0 == "ui" ? "UI" : $0.capitalized)``") },
                // /// > Complexity: `1/5`
                self.complexity
                    .map { .docLineComment("/// > Complexity: `\($0)/5`") },
                // /// > Latest Supported RPC Version: `1`
                self.rpcVersion
                    .map { .docLineComment("/// > Version: Latest Supported RPC Version - `\($0)`") },
                // /// > Added in v5.0.0
                self.initialVersion
                    .map { .docLineComment("/// > Since: Added in v\($0)") },
//                // Only print "Deprecated"
//                self.deprecated
//                    .flatMap { $0 ? .docLineComment("/// - Deprecated") : nil },
                self.valueRestrictions
                    .map { .docLineComment("/// > Value Restrictions: `\($0)`") },
                // /// > Added in v5.0.0
                self.valueOptionalBehavior
                    .map { .docLineComment("/// > Optional Behavior: \($0)") },
            ].compactMap { $0 }
        ).flatMap { [$0, .newlines(1)] })
    }
}
