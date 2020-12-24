//
//  FeatureService.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import AsyncHTTPClient

public struct FeatureService {
	public let url: URL
	var gis: GIS

	/// Feature Service
	/// - Parameters:
	///   - url: The URL to the Feature Server: "https://machine.domain.com/webadaptor/rest/services/USA/FeatureServer"
	///   - gis: gis
	public init(url: URL, gis: GIS) {
		self.url = url
		self.gis = gis

		do {
			try self.gis.refreshToken()

			let req = try! HTTPClient.Request(
				url: "\(url.absoluteString)?f=json\(gis.token != nil ? "&token=\(gis.token!)" : "")",
				method: .GET
			)

			let res = try gs.client.execute(request: req).wait()

			if res.status == .ok && res.body != nil {
				print(String(data: Data(buffer: res.body!), encoding: .utf8) ?? "")
			}
		} catch {

		}
	}
}
