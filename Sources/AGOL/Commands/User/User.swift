//
//  User.swift
//  
//
//  Created by Jeff Lebrun on 12/28/20.
//

import ArcGISKit
import ArgumentParser
import Foundation
import GetPass
import Rainbow

extension AGOLCommand {
	struct User: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage currently authenticated user.",
			subcommands: [View.self],
			defaultSubcommand: View.self
		)
	}
}
