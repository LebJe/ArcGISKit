//
//  main.swift
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//

import Foundation
import ArgumentParser
import ArcGISKit
import GetPass

struct AGOLCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "agol",
		abstract: "Command line tool to interact with ArcGIS Online.",
		version: "0.0.0",
		subcommands: [Auth.self]
	)
}

AGOLCommand.main()
