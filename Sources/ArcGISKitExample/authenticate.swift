// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import struct Foundation.URL
import GenericHTTPClient
import GHCAsyncHTTPClient
import GHCURLSession

func authenticate(username: String, password: String, url: URL) async -> Result<GIS, AGKError> {
	do {
		let gis = try await GIS(
			authentication: .credentials(username: username, password: password),
			url: url,
			client: URLSessionHTTPClient()
		)
		return .success(gis)
	} catch let error as AGKError {
		return .failure(error)
	} catch {
		fatalError()
	}
}
