//
//  Hello.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation
import CryptoKit

extension OBSOpData {
    /// First message sent from the server immediately on client connection.
    ///
    /// Contains authentication information if auth is required. Also contains RPC version
    /// for version negotiation.
    ///
    /// - term Sent From: `obs-websocket`
    /// - term Sent To: Freshly connected websocket client
    public struct Hello: OBSOpDataProtocol {
        public static let opCode: OBSWS.Enums.OpCode = .hello
        
        public let obsWebSocketVersion: String
        
        /// `rpcVersion` is a version number which gets incremented on each breaking change to the `obs-websocket`
        /// protocol.
        ///
        /// Its usage in this context is to provide the current rpc version that the server would like to use.
        public let rpcVersion: Int
        public let authentication: Authentication?
        
        internal init(
            obsWebSocketVersion: String,
            rpcVersion: Int,
            authentication: Authentication?
        ) {
            self.obsWebSocketVersion = obsWebSocketVersion
            self.rpcVersion = rpcVersion
            self.authentication = authentication
        }
        
        public struct Authentication: Sendable, Hashable, Codable {
            public let challenge: String
            public let salt: String
            
            internal init(challenge: String, salt: String) {
                self.challenge = challenge
                self.salt = salt
            }
        }
        
        /// Maps `Hello` instance to a new ``Identify`` message body.
        /// - Parameters:
        ///   - password: If provided, it's used with ``Hello/authentication`` to create a final
        ///   authentication string.
        ///   - events: If provided, it tells `obs-websocket` that it's interested in being
        ///   alerted about specific categories of ``OBSWS/Events``.
        /// - Throws: ``OBSWS/Error/missingPasswordWhereRequired`` if
        /// ``Hello/authentication`` is present without a provided password.
        /// - Returns: A new ``Identify`` message body with the generated authentication string.
        public func toIdentify(
            password: String?,
            subscribeTo events: OBSWS.Enums.EventSubscription?
        ) throws -> Identify {
            var auth: String? = nil
            
            // To generate the authentication string, follow these steps:
            if let a = authentication {
                if let pass = password,
                   !pass.isEmpty {
                    // Concatenate the websocket password with the salt provided by the server (password + salt)
                    let secretString = pass + a.salt
                    
                    // Generate an SHA256 binary hash of the result and base64 encode it, known as a base64 secret.
                    let secretHash = SHA256.hash(data: secretString.data(using: .utf8)!)
                    let encodedSecret = Data(secretHash)
                        .base64EncodedString()
                    
                    // Concatenate the base64 secret with the challenge sent by the server (base64_secret + challenge)
                    let authResponseString = encodedSecret + a.challenge
                    
                    // Generate a binary SHA256 hash of that result and base64 encode it. You now have your authentication string.
                    let authResponseHash = SHA256.hash(data: authResponseString.data(using: .utf8)!)
                    auth = Data(authResponseHash)
                        .base64EncodedString()
                } else {
                    // If there is authentication data in the Hello message, then it requires a password.
                    // If the user didn't enter a password where one is required, throw error.
                    throw OBSWS.Error.missingPasswordWhereRequired
                }
            }
            
            return Identify(rpcVersion: rpcVersion, authentication: auth, eventSubscriptions: events)
        }
    }
}
