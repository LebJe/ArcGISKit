import XCTest
@testable import ArcGISKit

final class ArcGISKitTests: XCTestCase {
	let env = ProcessInfo.processInfo.environment

    func testInitGIS() throws {
		XCTAssertNoThrow(try GIS(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"], url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!), "Initializing `GIS` with valid credentials should not throw.")

		let gis = try GIS(username: env["AGOL_USERNAME"] ?? "", password: env["AGOL_PASSWORD"], url: URL(string: env["AGOL_URL"] ?? "https://arcgis.com")!)

		var group = gis.user!.groups!.first(where: { $0.title! == "Housing Maintenance" })!

		group.fetchContent(from: gis)

		if case ContentType.featureServer(let fs) = group.content[0] {
			print(fs.featureService!)
		}

		//var fS = FeatureServer(url: URL(string: "https://services7.arcgis.com/V2n9y2bh8WyGKmfd/arcgis/rest/services/Campsite/FeatureServer")!, gis: gis)

		//fS.query(layerQueries: [FeatureServer.LayerQuery(whereClause: "1=1", layerID: "0")])
	}

    static var allTests = [
        ("Test initialing GIS", testInitGIS),
    ]
}
