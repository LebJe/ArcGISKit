//
//  Groups.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import ArgumentParser
import Foundation

extension AGOLCommand {
	struct Group: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage Groups.",
			subcommands: [View.self, List.self],
			defaultSubcommand: View.self
		)
	}
}


