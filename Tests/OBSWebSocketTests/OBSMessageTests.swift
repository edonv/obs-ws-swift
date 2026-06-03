//
//  OBSMessageTests.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/25/26.
//

import Foundation
import Testing
@testable import OBSWebSocket
import JSONValue

struct OBSMessageTests {
    private let untypedMessages: [OBSUntypedMessage] = [
        .init(operation: .hello, data: [
            "obsWebSocketVersion": "5.7.2",
            "rpcVersion": 1,
//            "authentication": nil,
        ]),
        .init(operation: .identify, data: [
            "rpcVersion": 1,
//            "authentication": nil,
            "eventSubscriptions": .int(OBSWS.Enums.EventSubscription.all.rawValue),
        ]),
        .init(operation: .identified, data: [
            "negotiatedRpcVersion": 1,
        ]),
        .init(operation: .reidentify, data: [
            "eventSubscriptions": .int(OBSWS.Enums.EventSubscription.all.rawValue),
        ]),
        .init(operation: .event, data: [
            "eventType": "CurrentSceneCollectionChanging",
            "eventIntent": .int(OBSWS.Enums.EventSubscription.config.rawValue),
            "eventData": [
                "sceneCollectionName": "New Scene Collection",
            ],
        ]),
        .init(operation: .request, data: [
            "requestType": "SetProfileParameter",
            "requestId": .string(UUID().uuidString),
            "requestData": [
                "parameterCategory": "category",
                "parameterName": "name",
                "parameterValue": "value",
            ],
        ]),
        .init(operation: .requestResponse, data: [
            "requestType": "GetProfileParameter",
            "requestId": .string(UUID().uuidString),
            "requestStatus": [
                "result": true,
                "code": .int(OBSWS.Enums.RequestStatus.success.rawValue),
                "comment": "Example comment",
            ],
            "responseData": [
                "parameterValue": "value",
                "defaultParameterValue": "default",
            ],
        ]),
        .init(operation: .requestBatch, data: [
            "requestId": .string(UUID().uuidString),
            "haltOnFailure": true,
            "executionType": .int(OBSWS.Enums.RequestBatchExecutionType.serialFrame.rawValue),
            "requests": [
                [
                    "requestType": "SetProfileParameter",
                    "requestId": .string(UUID().uuidString),
                    "requestData": [
                        "parameterCategory": "category",
                        "parameterName": "name",
                        "parameterValue": "value",
                    ],
                ],
            ],
        ]),
        .init(operation: .requestBatchResponse, data: [
            "requestId": .string(UUID().uuidString),
            "results": [
                [
                    "requestType": "GetProfileParameter",
                    "requestId": .string(UUID().uuidString),
                    "requestStatus": [
                        "result": true,
                        "code": .int(OBSWS.Enums.RequestStatus.success.rawValue),
                        "comment": "Example comment",
                    ],
                    "responseData": [
                        "parameterValue": "value",
                        "defaultParameterValue": "default",
                    ],
                ]
            ]
        ]),
    ]
    
    /// Test casting untyped messages to typed messages.
    @Test func untypedMessageCastingTest() async throws {
        for msg in untypedMessages {
            switch msg.operation {
            case .hello:
                let hello = try msg.as(OBS.OpData.Hello.self)
                #expect(hello.data == OBS.OpData.Hello(
                    obsWebSocketVersion: "5.7.2",
                    rpcVersion: 1,
                    authentication: nil
                ))
                
            case .identify:
                let identify = try msg.as(OBS.OpData.Identify.self)
                #expect(identify.data == OBS.OpData.Identify(
                    rpcVersion: 1,
                    authentication: nil,
                    eventSubscriptions: .all
                ))
                
            case .identified:
                let identified = try msg.as(OBS.OpData.Identified.self)
                #expect(identified.data == OBS.OpData.Identified(negotiatedRpcVersion: 1))
                
            case .reidentify:
                let reidentify = try msg.as(OBS.OpData.Reidentify.self)
                #expect(reidentify.data == OBS.OpData.Reidentify(eventSubscriptions: .all))
                
            case .event:
                let event1Msg = try msg.as(OBS.OpData.Event.self)
                let event2Data = try OBS.OpData.Event(
                    OBSWS.Events.CurrentSceneCollectionChanging(sceneCollectionName: "New Scene Collection")
                )
                #expect(event1Msg.data == event2Data)
                
            case .request:
                let req1Msg = try msg.as(OBS.OpData.Request.self)
                let req2Data = try OBS.OpData.Request(OBSWS.Requests.SetProfileParameter(
                    parameterCategory: "category",
                    parameterName: "name",
                    parameterValue: "value"
                ), id: req1Msg.data.id)
                #expect(req1Msg.data == req2Data)
                
            case .requestResponse:
                let resp1Msg = try msg.as(OBS.OpData.RequestResponse.self)
                let resp2Data = try OBS.OpData.RequestResponse(
                    OBSWS.Requests.GetProfileParameter.self,
                    id: resp1Msg.data.id,
                    status: .init(
                        result: true,
                        code: .success,
                        comment: "Example comment"
                    ),
                    response: .init(
                        parameterValue: "value",
                        defaultParameterValue: "default"
                    )
                )
                #expect(resp1Msg.data == resp2Data)
                
            case .requestBatch:
                let batch1Msg = try msg.as(OBS.OpData.RequestBatch.self)
                let batch2Data = OBS.OpData.RequestBatch(
                    id: batch1Msg.data.id,
                    haltOnFailure: true,
                    executionType: .serialFrame,
                    requests: [
                        try .init(
                            OBSWS.Requests.SetProfileParameter(
                                parameterCategory: "category",
                                parameterName: "name",
                                parameterValue: "value"
                            ),
                            id: batch1Msg.data.requests[0].id
                        )
                    ]
                )
                #expect(batch1Msg.data == batch2Data)
                
            case .requestBatchResponse:
                let batchResp1Msg = try msg.as(OBS.OpData.RequestBatchResponse.self)
                let batchResp2Data = try OBS.OpData.RequestBatchResponse(
                    id: batchResp1Msg.data.id,
                    results: [
                        .init(
                            OBSWS.Requests.GetProfileParameter.self,
                            id: batchResp1Msg.data.results[0].id,
                            status: .init(
                                result: true,
                                code: .success,
                                comment: "Example comment"
                            ),
                            response: .init(
                                parameterValue: "value",
                                defaultParameterValue: "default"
                            )
                        )
                    ]
                )
                #expect(batchResp1Msg.data == batchResp2Data)
            }
        }
    }
}
