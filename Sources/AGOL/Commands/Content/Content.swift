//
//  Content.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import ArgumentParser
import Foundation

extension AGOLCommand {
	struct Content: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage Content.",
			subcommands: [View.self, List.self],
			defaultSubcommand: List.self
		)
	}
}
