// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import _Concurrency
@testable import ArcGISKit
import NIO
import XCTest

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

	func testInitGIS() async throws {
		let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

		async { @MainActor in
			let gis = try await GIS(
				authentication: .credentials(
					username: self.env["AGOL_USERNAME"] ?? "",
					password: self.env["AGOL_PASSWORD"]!
				),
				eventLoopGroup: group,
				url: URL(string: self.env["AGOL_URL"] ?? "https://arcgis.com")!
			)

			print(try await gis.user.fullName)
		}
	}

	func testGenerateURL() throws {
		let generatedURL = GIS.generateURL(clientID: self.env["AGOL_CLIENT_ID"]!, baseURL: URL(string: self.env["AGOL_URL"]!)!).absoluteString

		let url = URL(string: env["AGOL_URL"]!)!
			.appendingPathComponent("sharing")
			.appendingPathComponent("rest")
			.appendingPathComponent("oauth2")
			.appendingPathComponent("authorize")
			.absoluteString

		let expectedURL = "\(url)?response_type=code&client_id=\(self.env["AGOL_CLIENT_ID"]!)&redirect_uri=urn:ietf:wg:oauth:2.0:oob"

		XCTAssertEqual(generatedURL, expectedURL, "`generatedURL` and `expectedURL` should be equal!")
	}

	static var allTests = [
		("Test initialing GIS", testInitGIS),
		("Test Generate URL", testGenerateURL),
	]
}
