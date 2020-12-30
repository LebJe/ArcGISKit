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
					print("ID: ".bold + user.id)
					print("Name: ".bold + (user.fullName ?? "No name"))
					print("Description: ".bold + (user.description != nil ? user.description!.isEmpty ? "No description" : user.description! : "No description"))
					print("Username: ".bold + user.username)
					print("Email: ".bold + (user.email ?? "No email"))
					if let tags = user.tags, !tags.isEmpty {
						print("Tags: ".bold, terminator: "")
						tags.forEach({ print("  \($0)") })
					} else {
						print("Tags: ".bold + "No tags.")
					}
				}
			} catch ConfigError.noConfigFile {
				print("You are not logged in. Log in using \"agol auth login\".")
			}
			catch GISError.invalidUsernameOrPassword {
				print("You logged in with an invalid username or password.".red)
			}
			catch {

			}
		}
	}
}
