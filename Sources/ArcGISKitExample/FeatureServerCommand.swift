// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct FeatureServerCommand: AsyncParsableCommand {
		static var configuration = CommandConfiguration(
			commandName: "feature-server",
			abstract: "View Feature Server details."
		)

		@OptionGroup var sharedOptions: ExamplesCommand.Options

		@Argument(help: "The URL of the Feature Server you wish to view.", transform: URL.init(string:))
		var featureServerURL: URL?

		func validate() throws {
			guard featureServerURL != nil else { throw ValidationError("The Feature Server URL must be valid.") }
		}

		func run() async throws {
			switch await authenticate(
				username: sharedOptions.username,
				password: sharedOptions.password,
				url: sharedOptions.organizationURL!
			) {
				case let .success(gis):
					let fs = FeatureServer(url: featureServerURL!, gis: gis)
					switch await fs.featureService {
						case let .success(featureService):
							var queries: [FeatureServer.LayerQuery] = []

							for layer in featureService.layers ?? [] {
								switch await fs.info(layerID: String(layer.id)) {
									case let .success(info):
										print("Layer \(layer.id) \(layer.name != nil ? "(\(layer.name!))" : "")")
										print()

										print("  Fields:")

										print("-------------------")
										for field in info.fields ?? [] {
											print()
											printField(field)
											print("-------------------")
										}

										if let geoField = info.geometryField {
											print()
											printField(geoField)
											print("-------------------")
										}
										print("---------------------------------------------")
									case let .failure(error): print(error)
								}

								queries.append(.init(whereClause: "1=1", layerID: String(layer.id)))
							}
						case let .failure(error): print(error)
					}

				case let .failure(error): print(error)
			}
		}
	}
}

func printField(_ field: TableField) {
	print("Name: " + field.name)
	print("Alias: " + (field.alias ?? ""))
	print("Field Type: " + field.type.rawValue)
	print("Is Editable: \(field.editable ?? false ? "true" : "false")")
	print("Is Nullable: \(field.nullable ? "true" : "false")")
	print("Length: \(field.length ?? 0)")
	print("Default Value: \(field.defaultValue ?? "(None)")")
	if let domain = field.domain {
		print("Domain:")

		print("  Name: \(domain.name ?? "(None)")")
		print("  Merge Policy: \(domain.mergePolicy ?? "(None)")")
		print("  Split Policy: \(domain.splitPolicy ?? "(None)")")
		print("  Type: \(domain.type.rawValue)")
		print("  Range: \(domain.range?.map(String.init).joined(separator: ", ") ?? "(None)")")

		print("  Coded Values:")
		print("  ----------")
		if domain.codedValues?.isEmpty ?? true {
			print("    - None")
		}
		for value in domain.codedValues ?? [] {
			print("  - Name: \(value.name ?? "(None)")")
			switch value.code {
				case let .left(str): print("    Value: \(str)")
				case let .right(int): print("    Value: \(int)")
				case nil: print("    Value: None")
			}

			print()
		}

		print("  ----------")
	}
}
