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

	/// Feature Service
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g: "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `GISError`.
	public init(url: URL, gis: GIS) throws {
		self.url = url
		self.gis = gis

		var fS: FeatureService? = nil
		do {
			try self.gis.refreshToken()

			let req = try! HTTPClient.Request(
				url: "\(url.absoluteString)?f=json\(gis.token != nil ? "&token=\(gis.token!)" : "")",
				method: .GET
			)

			let res = try gs.client.execute(request: req).wait()

			if res.status == .ok && res.body != nil {

				do {
					fS = try JSONDecoder().decode(FeatureService.self, from: Data(buffer: res.body!))
				} catch {
					throw GISError.fetchFeatureServiceFailed
				}
			}
		} catch {

		}

		self.featureService = fS
	}

	public mutating func query(layerQueries: [LayerQuery]) {
		do {
			try self.gis.refreshToken()

			let dict = layerQueries.map({ ["layerId": $0.layerID, "where": $0.whereClause, "outfields": "*"] })

			let req = try HTTPClient.Request(
				url: "\(url.appendingPathComponent("query").absoluteString)?f=json&layerDefs=\(String(data: try JSONEncoder().encode(dict), encoding: .utf8)!.urlQueryEncoded)\(gis.token != nil ? "&token=\(gis.token!)" : "")",
				method: .GET
			)

			let res = try gs.client.execute(request: req).wait()

			if res.status == .ok && res.body != nil {
				do {
					//print(String(data: Data(buffer: res.body!), encoding: .utf8)!)
				} catch {
					print(error)
				}
			} else {

			}
		} catch {
			print(error)
		}
	}
}

public extension FeatureServer {
	struct LayerQuery {
		let whereClause: String
		let layerID: String
	}
}
