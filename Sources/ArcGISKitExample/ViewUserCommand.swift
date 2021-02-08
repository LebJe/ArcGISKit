//
//  ViewUserCommand.swift
//
//
//  Created by Jeff Lebrun on 2/8/21.
//

import Foundation

import ArcGISKit
import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct ViewUserCommand: ParsableCommand {
		static var configuration = CommandConfiguration(commandName: "view-user", abstract: "View user details.")

		@OptionGroup var sharedOptions: ExamplesCommand.Options

		func run() throws {
			do {
				let gis = try authenticate(username: sharedOptions.username, password: sharedOptions.password, url: sharedOptions.organizationURL!)
				let user = try gis.fetchUser().wait()

				print("ID: " + user.id)
				print("Name: " + (user.fullName ?? ""))
				print("Username: " + user.username)
				print("Email Address: " + (user.email ?? ""))
				print("Description: " + (user.description ?? "No description"))
			} catch is AGKAuthError {
				print("Incorrect username or password.")
			}
		}
	}
}
