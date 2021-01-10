//
//  ViewG.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import ArcGISKit
import ArgumentParser
import Foundation
import Rainbow

extension AGOLCommand.Group {
	struct View: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "View details of a group that you are in..")

		@Argument(
			help: "The ID of the group that you want to view.",
			completion: .custom(
				{ currentlyTyped in
					do {
						let gis = try getGIS()
						if let groups = gis.user?.groups {
							return groups.map({ $0.id ?? "" })
						}
					} catch {}
					return []
				}
			)
		)
		var groupID: String

		func run() throws {
			do {
				let gis = try getGIS()
				if gis.isAnonymous {
					print("You cannot be in a group if you are an anonymous user.".yellow)
					Foundation.exit(1)
				}

				if let groups = gis.user?.groups {
					if let group = groups.first(where: { $0.id == groupID }) {
						print("Name: ".bold + (group.title ?? "No name."))
					} else {
						print("A group with the ID of \"\(groupID)\" does not exist.".red)
						Foundation.exit(2)
					}
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
