//
//  OBSMessageTests.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/25/26.
//

import Testing
import OBSWebSocket
import JSONValue

struct OBSMessageTests {
    private let messages: [OBSUntypedMessage] = [
        .init(operation: .hello, data: <#T##JSONValue#>),
        .init(operation: .identify, data: [
            "rpcVersion": 1,
            "authentication": nil,
            "eventSubscriptions": .int(OBSWS.Enums.EventSubscription.all.rawValue),
        ]),
        .init(operation: .identified, data: <#T##JSONValue#>),
        .init(operation: .reidentify, data: <#T##JSONValue#>),
        .init(operation: .event, data: <#T##JSONValue#>),
        .init(operation: .request, data: <#T##JSONValue#>),
        .init(operation: .requestResponse, data: <#T##JSONValue#>),
        .init(operation: .requestBatch, data: <#T##JSONValue#>),
        .init(operation: .requestBatchResponse, data: <#T##JSONValue#>),
    ]
    
    @Test func messageDecodeTest() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}
