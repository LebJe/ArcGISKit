//
//  FeatureServer.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import AsyncHTTPClient

/// A `FeatureServer` manages `FeatureService`s.
public struct FeatureServer: Equatable {
	public static func == (lhs: FeatureServer, rhs: FeatureServer) -> Bool {
		lhs.url == rhs.url && lhs.featureService == rhs.featureService
	}

	public let url: URL
	var gis: GIS
	public let featureService: FeatureService?

	public struct LayerQuery {
		public let whereClause: String
		public let layerID: String

		public init(whereClause: String, layerID: String) {
			self.whereClause = whereClause
			self.layerID = layerID
		}
	}

	/// Feature Service
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g: "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `RequestError`.
	public init(url: URL, gis: GIS) throws {
		self.url = url
		self.gis = gis

		var fS: FeatureService? = nil

		try self.gis.refreshToken()

		let req = try! HTTPClient.Request(
			url: "\(url.absoluteString)?f=json\(gis.token != nil ? "&token=\(gis.token!)" : "")",
			method: .GET
		)

		let res = try gs.client.execute(request: req).wait()

		self.featureService = try handle(response: res, decodeType: FeatureService.self)
	}

	/// Query the `FeatureServer`.
	/// - Parameter layerQueries: The queries you want to perform.
	/// - Returns: An `Array` of `FeatureLayer`s.
	public mutating func query(layerQueries: [LayerQuery]) throws -> [FeatureLayer] {
		try self.gis.refreshToken()

		let dict = layerQueries.map({ ["layerId": $0.layerID, "where": $0.whereClause, "outfields": "*"] })

		let req = try HTTPClient.Request(
			url: "\(url.appendingPathComponent("query").absoluteString)?f=json&layerDefs=\(String(data: try JSONEncoder().encode(dict), encoding: .utf8)!.urlQueryEncoded)\(gis.token != nil ? "&token=\(gis.token!)" : "")",
			method: .GET
		)

		let res = try gs.client.execute(request: req).wait()

		let qr = try handle(response: res, decodeType: QueryResponse.self)

		return qr.layers
	}
}
