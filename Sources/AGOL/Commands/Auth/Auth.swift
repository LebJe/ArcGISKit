//
//  Auth.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import ArcGISKit
import ArgumentParser
import Foundation
import Echo
import Rainbow

extension AGOLCommand {
	struct Auth: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage authentication to ArcGIS Online.",
			subcommands: [Login.self, Logout.self],
			defaultSubcommand: Login.self
		)
	}
}

