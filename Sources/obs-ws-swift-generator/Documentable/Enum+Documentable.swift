//
//  Enum+Documentable.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/19/26.
//

import Foundation

extension OBSWSProtocol.Enum.EnumIdentifier: Documentable {
    var documentation: Documentation {
        .init(
            description: description,
            rpcVersion: rpcVersion,
            deprecated: deprecated,
            initialVersion: initialVersion
        )
    }
}
