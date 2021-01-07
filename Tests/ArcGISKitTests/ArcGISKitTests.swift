import XCTest
@testable import ArcGISKit

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

    func testInitGIS() throws {
		XCTAssertNoThrow(try GIS(authType: .credentials(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"]!), url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!), "Initializing `GIS` with valid credentials should not throw.")
	}

	func testGenerateURL() throws {
		let url = GIS.url(clientID: env["AGOL_CLIENT_ID"]!, baseURL: URL(string: env["AGOL_URL"]!)!).absoluteString
		let expectedURL = "\(URL(string: env["AGOL_URL"]!)!.appendingPathComponent("sharing").appendingPathComponent("rest").appendingPathComponent("oauth2").appendingPathComponent("authorize").absoluteString)?response_type=code&client_id=\(env["AGOL_CLIENT_ID"]!)&redirect_uri=urn:ietf:wg:oauth:2.0:oob"

		XCTAssertEqual(url, expectedURL, "`url` and `expectedURL` should be equal!")

	}

    static var allTests = [
        ("Test initialing GIS", testInitGIS),
		("Test Generate URL", testGenerateURL)
    ]
}
