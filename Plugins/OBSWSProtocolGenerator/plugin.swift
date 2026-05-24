//
//  plugin.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 5/21/26.
//

import Foundation
import PackagePlugin

@main
struct OBSWSProtocolGenerator: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let generator = try context.tool(named: "obs-ws-swift-generator")
        let generatorExec = generator.url
        
        let outputURL = context.package.directoryURL
            .appending(components: "Sources", "OBSWebSocket", "Generated", "Types.swift")
        let outputPath = outputURL.path(percentEncoded: false)
        
        let process = try Process.run(
            generatorExec,
            arguments: ["--output", "\(outputPath)"]
        )
        process.waitUntilExit()
    }
}
