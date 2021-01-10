//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import ArcGISKit
import ArgumentParser
import Foundation
import Rainbow
import Table

extension AGOLCommand.FeatureLayer {
	struct View: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "View Feature Layer.")

		@Option(name: [.short, .long], help: "The amount of layers to print.")
		var numberOfLayers: Int?

		@Option(name: [.short, .long], help: "The where clause to use when querying the Feature Server.")
		var whereClause: String = "1=1"

		@Argument(
			help: "The URL of the Feature Server that contains the Feature Layer.",
			transform: URL.init(string:)
		)
		var featureServerURL: URL?

		func validate() throws {
			if featureServerURL == nil {
				throw ValidationError("Feature Server URL is invalid!".red)
			}
		}

		func run() throws {
			if let url = featureServerURL {
				do {
					let gis = try getGIS()
					var t = Table()
					var fS = try FeatureServer(url: url, gis: gis)

					var layerQueries: [FeatureServer.LayerQuery] = []

					if let l = fS.featureService?.layers {
						for layer in l {
							layerQueries.append(.init(whereClause: whereClause, layerID: "\(layer.id)"))
						}
						let layers = try fS.query(layerQueries: layerQueries)

						for layer in layers {

							print("Layer \(layer.id):".bold)

							var array = [layer.fields.map({ $0.alias ?? $0.name })]

							layer.features.forEach({ l in
								array.append(
									layer.fields
										.map({ f in f.name })
										.map({ l.attributes![$0].stringValue.truncate(length: 15) })
								)
							})

							t.put(array)
						}
					} else {
						print("Unable to retrieve feature layers.".yellow)
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
}
