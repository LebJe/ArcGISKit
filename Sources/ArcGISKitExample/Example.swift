// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArgumentParser
import Foundation
import struct Foundation.URL
import MultipartFormData

@main struct ExamplesCommand: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "examples",
		abstract: "ArcGISKit Examples.",
		subcommands: [FeatureServerCommand.self, ViewUserCommand.self],
		defaultSubcommand: ViewUserCommand.self
	)
}
