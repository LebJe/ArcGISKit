import XCTest
@testable import ArcGISKit

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

		XCTAssertNoThrow(try GIS(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"], url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!), "Initializing `GIS` with valid credentials should not throw.")

	}

    static var allTests = [
        ("testExample", testExample),
    ]
}
