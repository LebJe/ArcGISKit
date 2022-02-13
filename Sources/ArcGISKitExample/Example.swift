// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArgumentParser
import Foundation
import struct Foundation.URL
import MultipartFormData
import SwiftPrettyPrint

protocol AsyncParsableCommand: ParsableCommand {
	mutating func runAsync() async throws
}

extension ParsableCommand {
	static func main(_ arguments: [String]? = nil) async {
		do {
			var command = try parseAsRoot(arguments)
			if #available(macOS 12.0, *), var asyncCommand = command as? AsyncParsableCommand {
				try await asyncCommand.runAsync()
			} else {
				try command.run()
			}
		} catch {
			exit(withError: error)
		}
	}
}

struct ExamplesCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "examples",
		abstract: "ArcGISKit Examples.",
		subcommands: [FeatureServerCommand.self, ViewUserCommand.self],
		defaultSubcommand: ViewUserCommand.self
	)
}

@main enum Main {
	static func main() async throws {
		// // await ExamplesCommand.main()

		let gis = try await authenticate(username: "stan.lebrun_mec", password: "L0k@t!0NGIS", url: URL(string: "https://mec.maps.arcgis.com")!)

		do {
			let user = try await gis.user

			try await user.createFolder(name: "TestFolder3", gis: gis)

			let geoJSON = try String(contentsOf: URL(fileURLWithPath: "/Users/lebje/Programs/Tests/C++/ogrTest/data/TestLayer.geojson"))

			let res = try await user.addFile(
				name: "test.geojson",
				data: Data(geoJSON.utf8),
				folder: "TestFolder3",
				type: "GeoJson",
				tags: ["json", "tag1"],
				gis: gis
			)

			print(res)

			// //Pretty.prettyPrint(try await user.fetchContent(from: gis))
			// Pretty.prettyPrint(user)
			// // print("ID: " + user.id)
			// // print("Name: " + (user.fullName ?? ""))
			// // print("Username: " + user.username)
			// // print("Email Address: " + (user.email ?? ""))
			// // print("Description: " + (user.description ?? "No Description."))

			// let a = try await user.groups![0].fetchContent(from: gis)

			// print(a[0])

			// let fs = try FeatureServer(url: URL(string: "https://services4.arcgis.com/HVUXnkW0yn0UyfwE/arcgis/rest/services/Test1/FeatureServer")!, gis: gis)
			// for res in try await fs.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")]) {
			// 	for feature in res.features where feature.attributes!["Coop"] == "COOP" {
			// 		print(feature.attributes!)
			// 	}
			// }

		} catch {
			print(error)
		}
	}
}
