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
    
    @Option(
        name: [.short, .customLong("output")],
        completion: .file(extensions: ["swift"]),
        transform: { path in
            print("@Option:", path)
            return URL(fileURLWithPath: path)
        }
    )
    var outputFileURL: URL
    private var outputFilePath: String {
        if #available(macOS 13.0, *) {
            outputFileURL.path(percentEncoded: false)
        } else {
            outputFileURL.path
        }
    }
    
    func run() async throws {
        let protocolJSONData = try Data(contentsOf: GenerateCommand.protocolJSON)
        let obsProtocol = try! JSONDecoder().decode(OBSWSProtocol.self, from: protocolJSONData)
        
        let sourceFile = try obsProtocol.generate()
        
        try prepDestinationFile()
        try sourceFile.description.write(to: outputFileURL, atomically: true, encoding: .utf8)
        
        print("Wrote to file successfully.")
        throw ExitCode.success
    }
    
    private func prepDestinationFile() throws {
        if !FileManager.default.fileExists(atPath: outputFilePath) {
            let success = FileManager.default.createFile(atPath: outputFilePath, contents: nil)
            if !success {
                print("Failed to create file.")
                throw ExitCode.failure
            }
        }
    }
}
