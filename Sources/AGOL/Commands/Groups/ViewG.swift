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
			completion: .custom({ _ in groupCompletion() })
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
						print("ID: ".bold + (group.id ?? "No ID."))
						print("Name: ".bold + (group.title ?? "No name."))
						print("Owner: ".bold + (group.owner ?? "No owner."))
						print("Description: ".bold + (group.description ?? "No description."))
						print("Summary: ".bold + (group.snippet ?? "No summary."))
						print("Contact Info: ".bold + (group.phone ?? "No Contact Info."))
						print("Description: ".bold + (group.description ?? "No description."))
						print("My Favorite: ".bold + (group.isFav ? "True" : "False"))
						print("Created: ".bold + group.created.formatted)
						print("Modified: ".bold + group.modified.formatted)

						if let tags = group.typeKeywords, !tags.isEmpty {
							print("Keywords: ".bold)
							tags.forEach({ print("  \($0)") })
						} else {
							print("Keywords: ".bold + "No keywords.")
						}

						if let tags = group.tags, !tags.isEmpty {
							print("Tags: ".bold)
							tags.forEach({ print("  \($0)") })
						} else {
							print("Tags: ".bold + "No tags.")
						}
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
