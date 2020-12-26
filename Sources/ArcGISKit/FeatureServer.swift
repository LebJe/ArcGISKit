//
//  FeatureServer.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import AsyncHTTPClient

/// A `FeatureServer` manages `FeatureService`s.
public struct FeatureServer {
	public let url: URL
	var gis: GIS
	public let featureService: FeatureService?

	/// Feature Service
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g: "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	public init(url: URL, gis: GIS) {
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
					print(error)
					//print(String(data: Data(buffer: res.body!), encoding: .utf8) ?? "")
				}
			}
		} catch {

		}

		self.featureService = fS
	}
}
