//
//  FeatureLayer.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import ArcGISKit
import ArgumentParser
import Foundation
import Rainbow

extension AGOLCommand {
	struct FeatureLayer: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Manage Feature Servers.",
			subcommands: [View.self],
			defaultSubcommand: View.self
		)
	}
}

