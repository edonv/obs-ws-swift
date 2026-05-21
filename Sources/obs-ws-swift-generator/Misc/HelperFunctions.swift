//
//  HelperFunctions.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/18/26.
//

import Foundation

func camelize(_ string: String) -> String {
    guard !string.isEmpty else { return "" }
    var tempStr = string
    
    if tempStr.contains("_")
        && tempStr.allSatisfy({ $0.isUppercase }) {
        tempStr = tempStr
            .split(separator: "_")
            .map { $0.prefix(1) + $0.dropFirst().lowercased() }
            .joined()
    }
    
    // Catch single words that are all caps
    if tempStr.allSatisfy({ $0.isUppercase }) {
        return tempStr.lowercased()
    }
    
    return tempStr.prefix(1).lowercased() + tempStr.dropFirst()
}

func pascalize(_ string: String) -> String {
    camelize(string).replacingCharacters(
        in: string.startIndex..<string.index(after: string.startIndex),
        with: string.first!.uppercased()
    )
}

func splitByCapitals(_ string: String) -> [String] {
    string.enumerated().split { (i, char) in
        char.isUppercase || i == 0
    }
    .map { $0.map(\.element) }
    .map { String($0) }
}
