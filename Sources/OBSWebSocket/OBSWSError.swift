//
//  OBSWSError.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/24/26.
//

import Foundation

extension OBS {
    public enum Error: Swift.Error {
        case missingPasswordWhereRequired
        
        public var localizedDescription: String {
            switch self {
            case .missingPasswordWhereRequired:
                return "OBS requires a password and one wasn't given."
            }
        }
    }
}
