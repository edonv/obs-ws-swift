//
//  Event+Documentable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/19/26.
//

import Foundation

extension OBSWSProtocol.Event: Documentable {
    var documentation: Documentation {
        .init(
            description: description,
            eventSubscription: eventSubscription,
            category: category,
            complexity: complexity,
            rpcVersion: rpcVersion,
            deprecated: deprecated,
            initialVersion: initialVersion
        )
    }
}

extension OBSWSProtocol.Event.Field: Documentable {
    var documentation: Documentation {
        .init(
            description: valueDescription
        )
    }
}
