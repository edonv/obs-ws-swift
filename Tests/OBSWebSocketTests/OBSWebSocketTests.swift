import Testing
@testable import OBSWebSocket

struct OBSWebSocketTests {
    private let obs = OBSWebSocket()
    
    private func connect(
        subscribingTo eventSubscription: OBS.Enums.EventSubscription? = nil
    ) async throws {
        try await obs.connect(
            with: .init(
//                scheme: "wss",
                ipAddress: "192.168.1.178",
                port: 4455,
                password: "thisisatest",
                encodingProtocol: .json
            ),
            subscribingTo: eventSubscription
        )
    }
    
    @Test func webSocketConnection() async throws {
        try await connect(subscribingTo: .all)
        
        #expect(obs.activeConnectionDetails != nil)
        
        let events = obs.events.prefix(3)
        
        let task1 = Task {
            for try await event in events {
                print("Task 1:", event)
            }
        }
        
        let task2 = Task {
            for try await event in events {
                print("Task 2:", event)
            }
        }
        
        try await task1.value
        try await task2.value
        
        obs.disconnect(with: .invalidDataFieldType, reason: "This is a test")
    }
}
