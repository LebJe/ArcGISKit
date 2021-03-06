@testable import class ArcGISKit.GIS
import NIO
import XCTest

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

	func testInitGIS() throws {
		let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

		XCTAssertNoThrow(
			try GIS(.credentials(username: self.env["AGOL_USERNAME"] ?? "", password: self.env["AGOL_PASSWORD"]!), eventLoopGroup: group, url: URL(string: self.env["AGOL_URL"] ?? "https://arcgis.com")!).fetchUser(),
			"Initializing `GIS` with valid credentials and fetching user details should not throw."
		)
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
