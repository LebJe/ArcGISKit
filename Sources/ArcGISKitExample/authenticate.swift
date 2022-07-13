// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import ArcGISKitAsyncHTTPClient
import ArcGISKitURLSession
import struct Foundation.URL

func authenticate(username: String, password: String, url: URL) async throws -> GIS {
	let gis = try await GIS(
		authentication: .credentials(username: username, password: password),
		url: url,
		client: URLSessionHTTPClient()
	)
	return gis
}
