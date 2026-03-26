// Copyright (c) 2026 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import _Concurrency
@testable import ArcGISKit
import GHCAsyncHTTPClient
import XCTest

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

	func testInitGIS() async throws {
		let gis = try await GIS(
			authentication: .credentials(
				username: self.env["AGOL_USERNAME"] ?? "",
				password: XCTUnwrap(self.env["AGOL_PASSWORD"])
			),
			url: URL(string: self.env["AGOL_URL"] ?? "https://arcgis.com")!,
			client: AHCHTTPClient()
		)

		// try await print(gis.user.fullName)
	}

	func testGenerateURL() throws {
		let generatedURL = try GIS
			.generateURL(
				clientID: XCTUnwrap(self.env["AGOL_CLIENT_ID"]),
				baseURL: XCTUnwrap(try URL(string: XCTUnwrap(self.env["AGOL_URL"])))
			).absoluteString

		let url = try XCTUnwrap(try URL(string: XCTUnwrap(env["AGOL_URL"]))?
			.appendingPathComponent("sharing")
			.appendingPathComponent("rest")
			.appendingPathComponent("oauth2")
			.appendingPathComponent("authorize")
			.absoluteString)

		let expectedURL =
			"\(url)?response_type=code&client_id=\(self.env["AGOL_CLIENT_ID"]!)&redirect_uri=urn:ietf:wg:oauth:2.0:oob"

		XCTAssertEqual(generatedURL, expectedURL, "`generatedURL` and `expectedURL` should be equal!")
	}
}
