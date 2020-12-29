//
//  Logout.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import ArcGISKit
import ArgumentParser
import Files
import Foundation
import GetPass
import Rainbow

extension AGOLCommand.Auth {
	struct Logout: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "Log out from ArcGIS Online.")

		@Flag(name: [.short, .long], help: "Confirm that you want to logout from ArcGIS Online.")
		var yes: Bool = false

		func run() throws {
			if yes == true {
				try configFile().delete()
				print("Logged out.".green)
				Foundation.exit(0)
			}

			print("Are you sure you want to logout? [Y(es)/N(o)] ", terminator: "")

			switch (readLine() ?? "").lowercased() {
				case "y", "yes":
					try configFile().delete()
					print("Logged out.")
				default:
					Foundation.exit(0)
			}

		}
	}
}
