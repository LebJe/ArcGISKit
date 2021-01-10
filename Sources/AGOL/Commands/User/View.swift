//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/28/20.
//

import ArcGISKit
import ArgumentParser
import Files
import Foundation
import Rainbow

extension AGOLCommand.User {
	struct View: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "View current user's profile.")

		func run() throws {
			do {
				let gis = try getGIS()
				if gis.isAnonymous {
					print("Anonymous User".bold)
				}
				if let user = gis.user {
					let favoriteGroup: Group? = (user.groups ?? []).first(where: {$0.id == user.favGroupId ?? "" })

					print("ID: ".bold + user.id)
					print("Name: ".bold + (user.fullName ?? "No name"))
					print("Username: ".bold + user.username)
					print("Email: ".bold + (user.email ?? "No email"))
					print("Description: ".bold + (user.description != nil ? user.description!.isEmpty ? "No description" : user.description! : "No description"))
					print("Available Credits: ".bold + (user.availableCredits != nil ? String(user.availableCredits!) : "None"))
					print("Assigned Credits: ".bold + (user.assignedCredits != nil ? String(user.assignedCredits!) : "None"))
					print("Favorite Group: ".bold + (favoriteGroup?.title ?? "None"))
					print("Multi-factor Authentication: ".bold + (user.mfaEnabled ?? false ? "Enabled" : "Disabled"))

					if let tags = user.tags, !tags.isEmpty {
						print("Tags: ".bold)
						tags.forEach({ print("  \($0)") })
					} else {
						print("Tags: ".bold + "No tags.")
					}

					if let groups = user.groups, !groups.isEmpty {
						print("Groups I'm In: ".bold)
						groups.forEach({ print("  \($0.title ?? "")") })
					} else {
						print("Groups I'm In: ".bold + "None.")
					}
				}
			} catch ConfigError.noConfigFile {
				print("You are not logged in. Log in using \"agol auth login\".")
			}
			catch RequestError.invalidUsernameOrPassword {
				print("You logged in with an invalid username or password.".red)
			}
			catch {

			}
		}
	}
}
