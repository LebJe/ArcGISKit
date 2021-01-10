//
//  FeatureLayer.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import ArgumentParser
import Foundation

extension AGOLCommand {
	struct FeatureLayer: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage Feature Servers.",
			subcommands: [View.self],
			defaultSubcommand: View.self
		)
	}
}

