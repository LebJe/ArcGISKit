import XCTest
@testable import ArcGISKit

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

    func testInitGIS() throws {
		XCTAssertNoThrow(try GIS(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"], url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!), "Initializing `GIS` with valid credentials should not throw.")
	}

    static var allTests = [
        ("Test initialing GIS", testInitGIS),
    ]
}
