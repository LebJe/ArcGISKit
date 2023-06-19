// Copyright (c) 2023 Jeff Lebrun
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
			switch await authenticate(username: sharedOptions.username, password: sharedOptions.password, url: sharedOptions.organizationURL!) {
				case let .success(gis):
					switch await gis.user {
						case let .success(user):
							print("ID: " + user.id)
							print("Name: " + (user.fullName ?? ""))
							print("Username: " + user.username)
							print("Email Address: " + (user.email ?? ""))
							print("Description: " + (user.description ?? "No description"))
						case let .failure(error):
							print(error)
					}
				case let .failure(error):
					print(error)
			}
		}
	}
}
