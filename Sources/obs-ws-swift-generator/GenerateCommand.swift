//
//  GenerateCommand.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/17/26.
//

import Foundation
import ArgumentParser
import SwiftSyntax

@main
struct GenerateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "obs-ws-swift-generator",
        abstract: "Generate Swift types for the OBS WebSocket protocol, based on local protocol file."
    )
    
    private static let protocolJSON: URL = Bundle.module.url(
        forResource: "Resources/protocol",
        withExtension: "json"
    )!
    private static let outputDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    
    func run() async throws {
        let protocolJSONData = try Data(contentsOf: GenerateCommand.protocolJSON)
        let obsProtocol = try! JSONDecoder().decode(OBSWSProtocol.self, from: protocolJSONData)
        
        let protocolNamespaceEnum = try obsProtocol.generate()
        let sourceFile = SourceFileSyntax {
            protocolNamespaceEnum
        }
        
        print(sourceFile)
    }
}
