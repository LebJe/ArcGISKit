//
//  FeatureServerCommand.swift
//
//
//  Created by Jeff Lebrun on 2/4/21.
//

import ArcGISKit
import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct FeatureServerCommand: ParsableCommand {
		static var configuration = CommandConfiguration(commandName: "feature-server", abstract: "View Feature Server details.")

		@OptionGroup var sharedOptions: ExamplesCommand.Options

		@Argument(help: "The URL of the Feature Server you wish to view.", transform: URL.init(string:))
		var featureServerURL: URL?

		func validate() throws {
			guard featureServerURL != nil else { throw ValidationError("The Feature Server URL must be valid.") }
		}

		func run() throws {
			do {
				let gis = try authenticate(username: sharedOptions.username, password: sharedOptions.password, url: sharedOptions.organizationURL!)
				let fs = try FeatureServer(url: featureServerURL!, gis: gis)
				let featureService = try fs.fetchFeatureService().wait()

				var queries: [FeatureServer.LayerQuery] = []

				for layer in featureService.layers ?? [] {
					queries.append(.init(whereClause: "1=1", layerID: String(layer.id)))
				}

				let layers = try fs.query(layerQueries: queries).wait()
				for layer in layers {
					print("Layer \(layer.id)")
					print()

					for field in layer.fields {
						print("  Fields:")
						print()
						print("    Name: " + field.name)
						print("    Alias: " + (field.alias ?? ""))
						print("    Field Type: " + field.type.rawValue)
						print("-------------------")
					}
					print("---------------------------------------------")
				}
			} catch is AGKAuthError {
				print("Incorrect username or password.")
			}
		}
	}
}
