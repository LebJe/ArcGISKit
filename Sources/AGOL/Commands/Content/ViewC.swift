//
//  ViewC.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation
import ArgumentParser
import ArcGISKit

extension AGOLCommand.Content {
	struct View: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "View content.")

		@Option(
			name: [.short, .customLong("group")],
			help: "View the content in `group` instead of the current user.",
			completion: .custom({ _ in groupCompletion() })
		)
		var groupID: String?

		@Argument(
			help: "The ID of the content you want to view.",
			completion: .custom({ _ in userContentCompletion() })
		)
		var contentID: String

		func run() throws {
			do {
				var gis = try getGIS()
				if gis.isAnonymous {
					print("You must log in as an authenticated user to view content.".red)
					Foundation.exit(1)
				}

				if let groupID = groupID {
					if var group = gis.user!.groups?.first(where: { $0.id == groupID }) {
						try group.fetchContent(from: gis)
						if let item = group.content.first(where: {
							switch $0 {
								case .featureServer(featureServer: _, metadata: let m):
									return m.id == contentID
							}
						}) {
							switch item {
								case .featureServer(featureServer: let fS, metadata: let m):
									print(m.title?.bold ?? "")
									try printFeatureLayer(fS: fS)
									break
							}
						} else {
							print("An item with the ID of \"\(contentID)\" does not exist.".red)
							Foundation.exit(2)
						}
					}
				} else {
					try gis.user!.fetchContent(from: gis)
					if let item = gis.user!.content.first(where: {
						switch $0 {
							case .featureServer(featureServer: _, metadata: let m):
								return m.id == contentID
						}
					}) {
						switch item {
							case .featureServer(featureServer: let fS, metadata: let m):
								print(m.title?.bold ?? "")
								try printFeatureLayer(fS: fS)
								break
						}
					} else {
						print("An item with the ID of \"\(contentID)\" does not exist.".red)
						Foundation.exit(2)
					}
				}
			}  catch ConfigError.noConfigFile {
				print("You are not logged in. Log in using \"agol auth login\".")
			}
			catch RequestError.invalidUsernameOrPassword {
				print("You logged in with an invalid username or password.".red)
			}
		}
	}
}
