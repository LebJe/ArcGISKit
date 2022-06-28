// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct FeatureServerCommand: AsyncParsableCommand {
		static var configuration = CommandConfiguration(commandName: "feature-server", abstract: "View Feature Server details.")

		@OptionGroup var sharedOptions: ExamplesCommand.Options

		@Argument(help: "The URL of the Feature Server you wish to view.", transform: URL.init(string:))
		var featureServerURL: URL?

		func validate() throws {
			guard featureServerURL != nil else { throw ValidationError("The Feature Server URL must be valid.") }
		}

		func runAsync() async throws {
			do {
				let gis = try await authenticate(username: sharedOptions.username, password: sharedOptions.password, url: sharedOptions.organizationURL!)
				let fs = try FeatureServer(url: featureServerURL!, gis: gis)
				let featureService = try await fs.featureService

				var queries: [FeatureServer.LayerQuery] = []

				for layer in featureService.layers ?? [] {
					queries.append(.init(whereClause: "1=1", layerID: String(layer.id)))
				}

				let layers = try await fs.query(layerQueries: queries)
				for layer in layers {
					print("Layer \(layer.id)")
					print()

					print("  Fields:")

					print("-------------------")
					for field in layer.fields ?? [] {
						print()
						print("    Name: " + field.name)
						print("    Alias: " + (field.alias ?? ""))
						print("    Field Type: " + field.type.rawValue)
						print("-------------------")
					}
					print("---------------------------------------------")
				}
			} catch AGKAuthError.invalidUsernameOrPassword {
				print("Incorrect username or password.")
			} catch {
				print("An error occurred: \(error)")
			}
		}
	}
}
