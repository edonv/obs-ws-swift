import Testing
@testable import OBSWebSocket

struct OBSWebSocketTests {
    private let obsWS = OBSWebSocket()
    
    private func connect() async throws {
        try await obsWS.connect(
            with: .init(
//                scheme: "wss",
                ipAddress: "192.168.1.178",
                port: 4455,
                password: "thisisatest",
                encodingProtocol: .json
            ),
            subscribingTo: .all
        )
    }
    
    @Test func webSocketConnection() async throws {
        try await connect()
        
        #expect(obsWS.activeConnectionDetails != nil)
        
        let events = obsWS.events.prefix(3)
        
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
        
        obsWS.disconnect(with: .invalidDataFieldType, reason: "This is a test")
    }
}
