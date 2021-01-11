//
//  ListC.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation
import ArgumentParser
import ArcGISKit

extension AGOLCommand.Content {
	struct List: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "List the content owned by you or a group you are in.")

		@Option(
			name: [.short, .customLong("group")],
			help: "List the content in `group` instead of the current user.",
			completion: .custom({ _ in groupCompletion() })
		)
		var groupID: String?

		func run() throws {
			do {
				var gis = try getGIS()
				if gis.isAnonymous {
					print("You cannot be in a group if you are an anonymous user.".yellow)
					Foundation.exit(1)
				}

				if let gID = groupID {
					if var group = gis.user!.groups?.first(where: { $0.id == gID }) {
						try group.fetchContent(from: gis)

						for item in group.content {
							switch item {
								case .featureServer(featureServer: _, metadata: let m):
									print("ID: ".bold + (m.id ?? "No ID."))
									print("Title: ".bold + (m.title ?? "No title."))
									print("----------------------------------")
							}
						}
					}
				} else {
					try gis.user!.fetchContent(from: gis)

					for item in gis.user!.content {
						switch item {
							case .featureServer(featureServer: _, metadata: let m):
								print("ID: " + (m.id ?? "No ID."))
								print("Title: " + (m.title ?? "No title."))
								print("----------------------------------")
						}
					}
				}

			} catch ConfigError.noConfigFile {
				print("You are not logged in. Log in using \"agol auth login\".")
			}
			catch RequestError.invalidUsernameOrPassword {
				print("You logged in with an invalid username or password.".red)
			}
			catch {
				print(error)
			}

		}
	}
}
