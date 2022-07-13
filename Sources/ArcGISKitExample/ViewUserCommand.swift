// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import Foundation

import ArcGISKit
import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct ViewUserCommand: AsyncParsableCommand {
		static var configuration = CommandConfiguration(commandName: "view-user", abstract: "View user details.")

		@OptionGroup var sharedOptions: ExamplesCommand.Options

		func run() async throws {
			do {
				let gis = try await authenticate(username: sharedOptions.username, password: sharedOptions.password, url: sharedOptions.organizationURL!)
				let user = try await gis.user

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
