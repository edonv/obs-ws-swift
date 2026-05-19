//
//  Request+Documentable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/19/26.
//

import Foundation

extension OBSWSProtocol.Request: Documentable {
    var documentation: Documentation {
        .init(
            description: description,
            category: category,
            complexity: complexity,
            rpcVersion: rpcVersion,
            deprecated: deprecated,
            initialVersion: initialVersion
        )
    }
}

extension OBSWSProtocol.Request.RequestField: Documentable {
    var documentation: Documentation {
        .init(
            description: valueDescription,
            valueRestrictions: valueRestrictions,
            valueOptionalBehavior: valueOptionalBehavior
        )
    }
}

extension OBSWSProtocol.Request.ResponseField: Documentable {
    var documentation: Documentation {
        .init(
            description: valueDescription
        )
    }
}
