// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import ExtrasJSON
import Foundation
import GenericHTTPClient
import WebURL

/// A `FeatureServer` manages `FeatureService`s.
public struct FeatureServer {
	public static func == (lhs: FeatureServer, rhs: FeatureServer) -> Bool {
		lhs.url == rhs.url
	}

	public let url: WebURL
	public var gis: GIS

	public struct LayerQuery {
		public let whereClause: String
		public let layerID: String

		public init(whereClause: String, layerID: String) {
			self.whereClause = whereClause
			self.layerID = layerID
		}
	}

	public enum SQLFormat: String {
		case none
		case native
		case standard
	}

	/// Feature Server
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g:
	/// "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	public init(url: URL, gis: GIS) {
		self.url = WebURL(url.absoluteString)!
		self.gis = gis
	}

	/// Retrieves the `FeatureService` managed by this `FeatureServer`.
	public var featureService: Result<FeatureService, AGKError> {
		get async {
			var newURL = self.url
			newURL.formParams.f = "json"
			if let token = await self.gis.currentToken {
				newURL.formParams.token = token
			}

			let req = try! GHCHTTPRequest(url: newURL)

			switch await sendAndHandle(request: req, client: self.gis.httpClient, decodeType: FeatureService.self) {
				case let .success(fs): return .success(fs)
				case let .failure(error): return .failure(error)
			}
		}
	}

	public func append() {}

	public func info(layerID: String) async -> Result<FeatureLayerInfo, AGKError> {
		var newURL = self.url + layerID
		newURL.formParams.f = "json"
		if let token = await self.gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! GHCHTTPRequest(url: newURL)

		switch await sendAndHandle(request: req, client: self.gis.httpClient, decodeType: FeatureLayerInfo.self) {
			case let .success(fsLI): return .success(fsLI)
			case let .failure(error): return .failure(error)
		}
	}

	/// Query the `FeatureServer`.
	/// - Parameters:
	///   - layerQueries: The queries you want to perform.
	///   - returnGeometry: If `true``, the result includes the geometry associated with each feature returned.
	///   - returnObjectIDs: If `true`, the response only includes an array of object IDs for each layer.
	////    Otherwise, the response is a feature set.
	////    While there is a limit to the number of features included in the feature set response, there is no limit to the
	/// number of object IDs returned in the ID array response.
	///     Clients can exploit this to get all the query conforming object IDs by specifying `returnIdsOnly` as true and
	/// subsequently requesting feature sets for subsets of object IDs.
	///   - returnCount: If `true`, the response only includes the count (number of features/records) that would be
	/// returned by a query. Otherwise, the response is a feature set.
	///   - returnZ: If `true`, z-values are included in the results if the features have z-values. Otherwise, z-values are
	/// not returned.
	///     This parameter only applies if `returnGeometry` is `true` and at least one of the layer's `hasZ` properties is
	/// `true`.
	///   - returnM: If `true`, m-values are included in the results if the features have m-values. Otherwise, m-values are
	/// not returned.
	///     This parameter only applies if `returnGeometry`` is true and at least one of the layer's `hasM` properties is
	/// `true``.
	///   - geometryPrecision: The number of decimal places in the response geometries returned by the query operation.
	/// This applies to x- and y-values only (not m- or z-values).
	///   - returnTrueCurves: This option was added at 10.5. When set to true, the query returns true curves in output
	/// geometries. When set to `false`, curves are converted to densified polylines or polygons.
	///   - sqlFormat: [This parameter] can be either standard SQL-92 ``FeatureServer\SQLFormat\standard`` or it can use
	/// the native SQL of the underlying data store ``FeatureServer\SQLFormat\native``.
	///     The default is ``FeatureServer\SQLFormat\none``, which means the `sqlFormat` depends on the
	/// `useStandardizedQuery` parameter.
	///     Note: The SQL format ``FeatureServer\SQLFormat\native`` is supported only when `useStandardizedQuery` [is set
	/// to `false`].
	///   - useStandardizedQuery: TODO
	///   - gdbVersion: the geodatabase version to query. This parameter applies only if the `hasVersionedData` property of
	/// the service and the `isDataVersioned` property of the layers queried are `true`.
	///     If `gdbVersion` is not specified, the query will apply to the published map’s version. Example: gdbVersion =
	/// "SDE.DEFAULT"
	/// - Returns: An `Array` of `FeatureLayer`s.
	/// - Reference: https://developers.arcgis.com/rest/services-reference/enterprise/query-feature-service-.htm
	public func query(
		layerQueries: [Self.LayerQuery],
		returnGeometry: Bool = true,
		returnObjectIDs: Bool = false,
		returnCount: Bool = false,
		returnZ: Bool = false,
		returnM: Bool = false,
		geometryPrecision: Int? = nil,
		returnTrueCurves: Bool = false,
		sqlFormat: SQLFormat = .none,
		// useStandardizedQuery: Bool = false,
		gdbVersion: String? = nil
	) async -> Result<[FeatureLayer], AGKError> {
		let layerQueriesDict = layerQueries.map({ ["layerId": $0.layerID, "where": $0.whereClause, "outfields": "*"] })

		var newURL = self.url

		newURL.pathComponents += ["query"]
		do {
			try newURL.formParams += [
				"f": "json",
				"layerDefs": String(bytes: XJSONEncoder().encode(layerQueriesDict), encoding: .utf8)!,
				"returnGeometry": String(describing: returnGeometry),
				"returnIdsOnly": String(describing: returnObjectIDs),
				"returnCountOnly": String(describing: returnCount),
				"returnZ": String(describing: returnZ),
				"returnM": String(describing: returnM),
				"returnTrueCurves": String(describing: returnTrueCurves),
				"sqlFormat": sqlFormat.rawValue,
			]

			if let geometryPrecision {
				newURL.formParams.geometryPrecision = String(geometryPrecision)
			}

			if let gdbVersion {
				newURL.formParams.gdbVersion = gdbVersion
			}
		} catch let error as EncodingError {
			return .failure(.requestError(.encodingError(error)))
		} catch {
			fatalError("Unexpected error: \(error)")
		}

		if let token = await self.gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! GHCHTTPRequest(url: newURL)

		switch await sendAndHandle(request: req, client: self.gis.httpClient, decodeType: QueryResponse.self) {
			case var .success(qr):
				for i in 0..<qr.layers.count {
					for j in 0..<qr.layers[i].features.count {
						qr.layers[i].featureServerURL = self.url
						qr.layers[i].features[j].featureServerURL = self.url
						qr.layers[i].features[j].featureLayerID = qr.layers[i].id
					}
				}
				return .success(qr.layers)
			case let .failure(error): return .failure(error)
		}
	}

	/// Deletes `features` from the `FeatureLayer` with the id of `id`.
	///
	/// - Parameters:
	///   - featureIDs: The ID of the `Feature`s you wish to delete.
	///   - id: The ID of the `FeatureLayer` you wish to delete the features from.
	///   - gdbVersion: The version of the geo-database you want to delete features from.
	/// - Returns: `[EditResponse]`.
	///
	/// To delete the first feature from the first layer, you could write:
	/// ```swift
	/// let result = await myFeatureServer
	/// 	.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///
	/// switch result {
	///  	case .success(let layers):
	/// 		let feature = layers[0].features[0]
	/// 		let res = await myFeatureServer
	/// 			.delete([feature.attributes!["OBJECTID"].intValue], from: String(layers[0].id))
	/// 	case .failure(let error): ...
	/// }
	///
	/// ```
	public func delete(
		_ featureIDs: [Int],
		from id: String,
		gdbVersion: String? = nil
	) async -> Result<[EditResponse], AGKError> {
		await self.edit([.init(id: id, deletes: featureIDs)], gdbVersion: gdbVersion)
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
	public func add(
		_ features: [AGKFeature],
		to id: String,
		gdbVersion: String? = nil,
		datumTransformation: DatumTransformation? = nil
	) async -> Result<[EditResponse], AGKError> {
		await self.edit([.init(id: id, adds: features)], gdbVersion: gdbVersion, datumTransformation: datumTransformation)
	}

	/// Updates `features` in the `FeatureLayer` with the id of `id`.
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
	public func update(
		_ features: [AGKFeature],
		in id: String,
		gdbVersion: String? = nil,
		datumTransformation: DatumTransformation? = nil
	) async -> Result<[EditResponse], AGKError> {
		await self.edit([.init(id: id, updates: features)], gdbVersion: gdbVersion, datumTransformation: datumTransformation)
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
	func edit(
		_ aud: [AddUpdateDelete],
		gdbVersion: String? = nil,
		datumTransformation: DatumTransformation? = nil
	) async -> Result<[EditResponse], AGKError> {
		var newURL = self.url
		newURL.pathComponents += ["applyEdits"]

		let d = try! String(bytes: XJSONEncoder().encode(aud), encoding: .utf8)!

		let dt: String?

		if let datumTransformation {
			dt = try! String(bytes: XJSONEncoder().encode(datumTransformation), encoding: .utf8)!
		} else { dt = nil }

		let req = try! await GHCHTTPRequest(
			url: newURL,
			method: .POST,
			headers: ["Content-Type": "application/x-www-form-urlencoded"],
			body: .string(
				"""
				f=json&edits=\(d.urlQueryEncoded)\(
					self.gis
						.currentToken != nil ? "&token=\(self.gis.currentToken!)" : ""
				)\(
					gdbVersion != nil ?
						"&gdbVersion=\(gdbVersion!.urlQueryEncoded)" : ""
				)
				\(
					dt != nil ?
						"&datumTransformation=\(dt!.urlQueryEncoded)" : ""
				)
				"""
			)
		)

		switch await sendAndHandle(request: req, client: self.gis.httpClient, decodeType: [EditResponse].self) {
			case let .success(editRes): return .success(editRes)
			case let .failure(error): return .failure(error)
		}
	}
}

struct AddUpdateDelete: Codable {
	let id: String
	var updates: [AGKFeature] = []
	var deletes: [Int] = []
	var adds: [AGKFeature] = []

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

	@FallbackDecoding<EmptyArray>
	public var addResults: [EditResult]

	@FallbackDecoding<EmptyArray>
	public var updateResults: [EditResult]
}

public struct EditResult: Codable {
	public let objectId: Int?
	public let uniqueId: Int?
	public let globalId: String?
	public let success: Bool
}
