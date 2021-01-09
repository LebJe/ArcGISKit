//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import ArcGISKit
import ArgumentParser
import Files
import Foundation
import Rainbow
import Table

extension AGOLCommand.FeatureLayer {
	struct View: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "View Feature Layer.")
		

		@Argument(
			help: "The URL of the Feature Server that contains the Feature Layer.",
			completion: .custom({ currentlyTyped in
				do {
					var gis = try getGIS()
					try gis.user!.fetchContent(from: gis)
					for c in gis.user!.content {
						switch c {
							case let ContentType.featureServer(featureServer: f, metadata: m):
								if f.url.absoluteString.contains(currentlyTyped[0]) {
									return [f.url.absoluteString]
								}
							default:
								return []
						}
					}

					return []
				} catch {
					return []
				}
			}), transform: URL.init(string:)
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
					let layers = fS.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])

					var array = [layers[0].fields.map({ $0.alias ?? $0.name })]

					layers[0].features.forEach({ l in
						array.append(
							layers[0].fields
								.map({ f in f.name })
								.map({ l.attributes![$0].stringValue })
						)
					})					

					t.put(array)
				} catch ConfigError.noConfigFile {
					print("You are not logged in. Log in using \"agol auth login\".")
				}
				catch GISError.invalidUsernameOrPassword {
					print("You logged in with an invalid username or password.".red)
				}

			}
		}
	}
}
