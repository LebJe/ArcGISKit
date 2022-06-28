// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import AsyncHTTPClient
import ExtrasJSON
import Foundation
import NIO
import WebURL

/// A `FeatureServer` manages `FeatureService`s.
public struct FeatureServer {
	public static func == (lhs: FeatureServer, rhs: FeatureServer) -> Bool {
		lhs.url == rhs.url
	}

	public let url: WebURL
	var gis: GIS

	public struct LayerQuery {
		public let whereClause: String
		public let layerID: String

		public init(whereClause: String, layerID: String) {
			self.whereClause = whereClause
			self.layerID = layerID
		}
	}

	/// Feature Server
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g: "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKRequestError`.
	public init(url: URL, gis: GIS) {
		self.url = WebURL(url.absoluteString)!
		self.gis = gis
	}

	/// Retrieves the `FeatureService` managed by this `FeatureServer`.
	/// - Throws: `AGKRequestError`.
	public var featureService: FeatureService {
		get async throws {
			var newURL = self.url
			newURL.formParams.f = "json"
			if let token = await self.gis.currentToken {
				newURL.formParams.token = token
			}

			let req = try! HTTPClient.Request(url: newURL, method: .GET)

			return try handle(response: try await self.gis.client.execute(request: req).get(), decodeType: FeatureService.self)
		}
	}

	public func append() {}

	public func info(layerID: String) async throws -> FeatureLayerInfo {
		var newURL = self.url + layerID
		newURL.formParams.f = "json"
		if let token = await self.gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! HTTPClient.Request(url: newURL, method: .GET)

		return try handle(response: try await self.gis.client.execute(request: req).get(), decodeType: FeatureLayerInfo.self)
	}

	/// Query the `FeatureServer`.
	/// - Parameter layerQueries: The queries you want to perform.
	/// - Returns: An `Array` of `FeatureLayer`s.
	/// - Throws: `AGKRequestError`.
	public func query(layerQueries: [Self.LayerQuery]) async throws -> [FeatureLayer] {
		let layerQueriesDict = layerQueries.map({ ["layerId": $0.layerID, "where": $0.whereClause, "outfields": "*"] })

		var newURL = self.url

		newURL.pathComponents += ["query"]
		newURL.formParams += [
			"f": "json",
			"layerDefs": String(bytes: try XJSONEncoder().encode(layerQueriesDict), encoding: .utf8)!,
		]

		if let token = await self.gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! HTTPClient.Request(url: newURL, method: .GET)

		var qr = try! handle(response: try await self.gis.client.execute(request: req).get(), decodeType: QueryResponse.self)

		for i in 0..<qr.layers.count {
			for j in 0..<qr.layers[i].features.count {
				qr.layers[i].featureServerURL = self.url
				qr.layers[i].features[j].featureServerURL = self.url
				qr.layers[i].features[j].featureLayerID = qr.layers[i].id
			}
		}
		return qr.layers
	}

	/// Deletes `features` from the `FeatureLayer` with the id of `id`.
	///
	/// - Parameters:
	///   - featureIDs: The ID of the `Feature`s you wish to delete.
	///   - id: The ID of the `FeatureLayer` you wish to delete the features from.
	///   - gdbVersion: The version of the geo-database you want to delete features from.
	/// - Throws: `AGKRequestError`
	/// - Returns: `[EditResponse]`.
	///
	/// To delete the first feature from the first layer, you could write:
	/// ```swift
	/// let layers = try await myFeatureServer
	/// 	.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///
	/// let feature = layers[0].features[0]
	/// let res = try await myFeatureServer
	/// 	.delete([feature.attributes!["OBJECTID"].intValue], from: String(layers[0].id))
	/// ```
	public func delete(_ featureIDs: [Int], from id: String, gdbVersion: String? = nil) async throws -> [EditResponse] {
		try await self.edit([.init(id: id, deletes: featureIDs)], gdbVersion: gdbVersion)
	}

	/// Adds `features` to the `FeatureLayer` with the id of `id`.
	///
	/// - Parameters:
	///   - features: The `Feature`s you wish to add.
	///   - id: The ID of the `FeatureLayer` you wish to add the `features` to.
	///   - gdbVersion: The version of the geo-database you want to add features to.
	/// - Throws: `AGKRequestError`
	/// - Returns: `[EditResponse]`.
	///
	/// To add a feature to the first layer, you could write:
	///	```swift
	///	let layers = try await myFeatureServer
	///		.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	/// var attributes = JSON()
	/// attributes["Greeting"] = "Hi!"
	///
	/// let feature = Feature(geometry: Geometry(x: 0.0, y: 0.0, rings: nil), attributes: attributes)
	///
	/// let res = try await myFeatureServer.add([feature], to: "0")
	///	```
	public func add(_ features: [Feature], to id: String, gdbVersion: String? = nil) async throws -> [EditResponse] {
		try await self.edit([.init(id: id, adds: features)], gdbVersion: gdbVersion)
	}

	/// Updates `features` in the `FeatureLayer` with the id of `id`.
	///

	///
	/// - Parameters:
	///   - features: The `Feature`s you wish to update.
	///   - id: The ID of the `FeatureLayer` that contains the `Feature`s you wish to update.
	///   - gdbVersion: The version of the geo-database you want to update features in.
	/// - Throws: `AGKRequestError`
	/// - Returns: `[EditResponse]`.
	///
	/// To change the value of `Greeting` to "Hi!", you could write:
	///	```swift
	///	let layers = try await myFeatureServer
	///		.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///
	/// var feature = layers[0].features[0]
	/// feature.attributes!["Greeting"] = "Hi!"
	/// let res = try await myFeatureServer.update([feature], in: "0")
	///	```
	public func update(_ features: [Feature], in id: String, gdbVersion: String? = nil) async throws -> [EditResponse] {
		try await self.edit([.init(id: id, updates: features)], gdbVersion: gdbVersion)
	}

	/// Edit the attributes in the `FeatureLayer`s that are contained within this `FeatureServer`.
	///
	/// To change `Greeting` to "Hello", you could write:
	///

	///
	/// - Parameter aud: The values you wish to edit, delete, or add.
	/// - Throws: `AGKRequestError`.
	/// - Returns: `[EditResponse]`.
	///
	/// ```swift
	///	let layers = try await myFeatureServer.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	/// var feature = layers[0].features[0]
	/// feature.attributes!["Greeting"] = "Hello!"
	///	let res = try await myFeatureServer.edit([A(id: "0", updates: [feature])])
	///	```
	func edit(_ aud: [AddUpdateDelete], gdbVersion: String? = nil) async throws -> [EditResponse] {
		var newURL = self.url
		newURL.pathComponents += ["applyEdits"]

		var req = try! HTTPClient.Request(url: newURL, method: .POST)

		let d = try! String(bytes: XJSONEncoder().encode(aud), encoding: .utf8)!

		req.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")

		req.body = .string(
			"""
			f=json&edits=\(d.urlQueryEncoded)\(await self.gis.currentToken != nil ? "&token=\(await self.gis.currentToken!)" : "")\(gdbVersion != nil ? "&gdbVersion=\(gdbVersion!.urlQueryEncoded)" : "")
			"""
		)

		return try! handle(response: try await self.gis.client.execute(request: req).get(), decodeType: [EditResponse].self)
	}
}

struct AddUpdateDelete: Codable {
	let id: String
	var updates: [Feature] = []
	var deletes: [Int] = []
	var adds: [Feature] = []

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Self.CodingKeys)
		try container.encode(self.id, forKey: .id)
		if !self.updates.isEmpty { try container.encodeIfPresent(self.updates, forKey: .updates) }
		if !self.deletes.isEmpty { try container.encodeIfPresent(self.deletes, forKey: .deletes) }
		if !self.adds.isEmpty { try container.encodeIfPresent(self.adds, forKey: .adds) }
	}
}

public struct EditResponse: Codable {
	public let id: Int
	public let addResults: [EditResult]?
	public let updateResults: [EditResult]?
}

public struct EditResult: Codable {
	public let objectId: Int
	public let uniqueId: Int?
	public let globalId: String?
	public let success: Bool
}
