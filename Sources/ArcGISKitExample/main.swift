//
//  main.swift
//
//
//  Created by Jeff Lebrun on 2/4/21.
//

import ArcGISKit
import ArgumentParser

struct ExamplesCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "examples",
		abstract: "ArcGISKit Examples.",
		subcommands: [FeatureServerCommand.self, ViewUserCommand.self],
		defaultSubcommand: ViewUserCommand.self
	)
}

ExamplesCommand.main()
