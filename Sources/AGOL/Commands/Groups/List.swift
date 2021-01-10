//
//  List.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation
import ArgumentParser
import ArcGISKit

extension AGOLCommand.Group {
	struct List: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "List all the groups you are in.")

		func run() throws {
			do {
				let gis = try getGIS()
				if gis.isAnonymous {
					print("You cannot be in a group if you are an anonymous user.".yellow)
					Foundation.exit(1)
				}

				if let groups = gis.user?.groups {
					groups.forEach({
						print("\($0.title?.bold ?? "") (\($0.id ?? ""))")
					})
				}

			} catch ConfigError.noConfigFile {
				print("You are not logged in. Log in using \"agol auth login\".")
			}
			catch RequestError.invalidUsernameOrPassword {
				print("You logged in with an invalid username or password.".red)
			}

		}
	}
}
