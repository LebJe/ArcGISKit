//
//  User.swift
//  
//
//  Created by Jeff Lebrun on 12/28/20.
//

import ArgumentParser
import Foundation

extension AGOLCommand {
	struct User: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage currently authenticated user.",
			subcommands: [View.self],
			defaultSubcommand: View.self
		)
	}
}
