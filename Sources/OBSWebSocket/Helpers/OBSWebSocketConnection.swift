//
//  OBSWebSocketConnection.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/26/26.
//

import Foundation

extension OBSWebSocket {
    /// A container type for managing information for connecting to `obs-websocket`.
    public struct Connection: Sendable, Hashable, Codable {
        // MARK: - Stored Properties
        
        /// URL scheme to use.
        public let scheme: String
        
        /// IP address of the `obs-websocket` server.
        public let ipAddress: String
        
        /// Port number of the `obs-websocket` server.
        public let port: Int
        
        /// Password for `obs-websocket` connection, if authentication is turned on.
        public let password: String?
        
        /// Which method of encoding messages the connection should use.
        public let encodingProtocol: MessageEncoding?
        
        // MARK: - Initializers
        
        /// Memberwise initializer.
        public init(
            scheme: String = "ws",
            ipAddress: String,
            port: Int,
            password: String?,
            encodingProtocol: MessageEncoding? = nil
        ) {
            self.scheme = scheme
            self.ipAddress = ipAddress
            self.port = port
            self.password = password
            self.encodingProtocol = encodingProtocol
        }
        
        /// Initializes connection data from a [`URL`](https://developer.apple.com/documentation/foundation/url).
        public init?(
            fromUrl url: URL,
            encodingProtocol: MessageEncoding? = nil
        ) {
            var request = URLRequest(url: url)
            request.webSocketProtocolHeader = encodingProtocol
            
            self.init(
                fromUrlRequest: request
            )
        }
        
        /// Initializes connection data from a [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest).
        ///
        /// `encodingProtocol` can be specified in the `request` parameter by setting the appropriate header field (``Connection/encodingProtocolHeaderKey``) to a supported value (``MessageEncoding``).
        /// - Parameters:
        ///   - request: A preconfigured `URLRequest`.
        ///   - encodingProtocol: The type of encoding to use when communicating with `obs-websocket`, if not already included in `request` as a header field.
        public init?(
            fromUrlRequest request: URLRequest
        ) {
            guard let url = request.url,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let scheme = components.scheme,
                  let ipAddress = components.host,
                  let port = components.port else { return nil }
            
            self.scheme = scheme
                .replacingOccurrences(of: "obsws", with: "ws")
            
            self.ipAddress = ipAddress
            self.port = port
            
            let path = components.path.replacingOccurrences(of: "/", with: "")
            self.password = path.isEmpty ? nil : path
            
            self.encodingProtocol = request.webSocketProtocolHeader
        }
        
        // MARK: - Computed Properties
        
        /// An assembled `String` of the full [`URL`](https://developer.apple.com/documentation/foundation/url).
        public var urlString: String {
            var str = "\(scheme)://\(ipAddress):\(port)"
            if let pass = password, !pass.isEmpty {
                str += "/\(pass)"
            }
            return str
        }
        
        /// A [`URL`](https://developer.apple.com/documentation/foundation/url) initialized
        /// from ``Connection/urlString``.
        public var url: URL? {
            return URL(string: urlString)
        }
        
        /// A [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest) initialized
        /// from ``Connection/url`` and ``Connection/encodingProtocol``, if not `nil`.
        public var urlRequest: URLRequest? {
            guard let url = self.url else { return nil }
            
            var req = URLRequest(url: url)
            req.webSocketProtocolHeader = encodingProtocol
            
            return req
        }
        
        /// Mode for encoding messages.
        public enum MessageEncoding: String, Sendable, Hashable, Codable {
            /// JSON over text frames
            case json = "obswebsocket.json"
            /// MsgPack over binary frames
            case msgPack = "obswebsocket.msgpack"
        }
    }
}
