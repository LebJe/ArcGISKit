import XCTest
@testable import ArcGISKit
import NIO

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

    func testInitGIS() throws {
		let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

		XCTAssertNoThrow(
			try GIS(.credentials(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"]!), eventLoopGroup: group, url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!).fetchUser(),
			"Initializing `GIS` with valid credentials and fetching user details should not throw."
		)
	}

	func testGenerateURL() throws {
		let url = GIS.generateURL(clientID: env["AGOL_CLIENT_ID"]!, baseURL: URL(string: env["AGOL_URL"]!)!).absoluteString
		let expectedURL = "\(URL(string: env["AGOL_URL"]!)!.appendingPathComponent("sharing").appendingPathComponent("rest").appendingPathComponent("oauth2").appendingPathComponent("authorize").absoluteString)?response_type=code&client_id=\(env["AGOL_CLIENT_ID"]!)&redirect_uri=urn:ietf:wg:oauth:2.0:oob"

		XCTAssertEqual(url, expectedURL, "`url` and `expectedURL` should be equal!")
	}

    static var allTests = [
        ("Test initialing GIS", testInitGIS),
		("Test Generate URL", testGenerateURL)
    ]
}
