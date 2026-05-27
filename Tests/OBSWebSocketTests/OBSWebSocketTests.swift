import Testing
@testable import OBSWebSocket

struct OBSWebSocketTests {
    @Test func webSocketConnection() async throws {
        let obsWS = OBSWebSocket()
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
        
        #expect(obsWS.activeConnectionDetails != nil)
        
        try await Task.sleep(for: .seconds(5))
        
        obsWS.disconnect(with: .invalidDataFieldType, reason: "This is a test")
        
//        for try await msg in obsWS.messages {
//            print(msg)
//        }
    }
}
