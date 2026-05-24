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
    
    let possibleSeparators: [Character] = ["_", " "]
    
    // If string does not contain an allowed separator...
    if !string.contains(where: { possibleSeparators.contains($0) }) {
        // Add a space before each uppercase character
        // Move backwards through indices
        var i = tempStr.index(before: tempStr.endIndex)
        func moveIndexBack() {
            guard i > tempStr.startIndex else { return }
            i = tempStr.index(before: i)
        }
        
        while i > tempStr.startIndex {
            if tempStr[i].isUppercase {
                tempStr.insert(" ", at: i)
                moveIndexBack()
            }
            
            moveIndexBack()
        }
    }
    
    tempStr = tempStr
        .split { possibleSeparators.contains($0) }
        .enumerated().map { i, str in
            guard i > 0 else { return str.lowercased() }
            return str.prefix(1).uppercased() + str.dropFirst().lowercased()
        }
        .joined()
    
    return tempStr
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
