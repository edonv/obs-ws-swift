//
//  HelperFunctions.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/18/26.
//

import Foundation

/// Will work on any string that either: (a) is separated by an underscore (`"_"`) or a space (`" "`),
/// or (b) is already in PascalCase or camelCase.
///
/// > Important: Will NOT work on string that are in all caps AND have no implied separator.
func camelize(_ string: String) -> String {
    guard !string.isEmpty else { return "" }
    var tempStr = string
    
    let possibleSeparators: [Character] = ["_", " "]
    
    let split: [String]
    if tempStr.contains(where: { possibleSeparators.contains($0) }) {
        split = tempStr
            .split { possibleSeparators.contains($0) }
            .map(String.init)
    } else {
        split = splitByCapitals(tempStr)
    }
    
    tempStr = split
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

/// Will work on any string that is already in PascalCase or camelCase.
///
/// > Important: Will NOT work on string that are in all caps OR have no implied separator.
func splitByCapitals(_ string: String) -> [String] {
    string.reduce(into: [String]()) { prev, char in
        if prev.isEmpty {
            prev.append("")
        }
        
        if char.isUppercase {
            prev.append(String(char))
        } else {
            prev[prev.count - 1].append(String(char))
        }
    }
    .filter { !$0.isEmpty }
}
