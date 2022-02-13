// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArgumentParser
import Foundation
import struct Foundation.URL
import MultipartFormData
import SwiftPrettyPrint

protocol AsyncParsableCommand: ParsableCommand {
	mutating func runAsync() async throws
}

extension ParsableCommand {
	static func main(_ arguments: [String]? = nil) async {
		do {
			var command = try parseAsRoot(arguments)
			if #available(macOS 12.0, *), var asyncCommand = command as? AsyncParsableCommand {
				try await asyncCommand.runAsync()
			} else {
				try command.run()
			}
		} catch {
			exit(withError: error)
		}
	}
}

@main struct ExamplesCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "examples",
		abstract: "ArcGISKit Examples.",
		subcommands: [FeatureServerCommand.self, ViewUserCommand.self],
		defaultSubcommand: ViewUserCommand.self
	)
}
