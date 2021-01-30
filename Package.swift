// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "ArcGISKit",
	platforms: [.macOS(.v10_15)],
	products: [
		.library(
			name: "ArcGISKit",
			targets: ["ArcGISKit"]
		),
	],
	dependencies: [
		// HTTP client library built on SwiftNIO
		.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.2"),

		// A Collection of PropertyWrappers to make custom Serialization of Swift Codable Types easy
		.package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", .upToNextMajor(from: "2.0.0")),

		// The better way to deal with JSON data in Swift.
		.package(url: "https://github.com/mlilback/SwiftyJSON.git", .revision("5bcfbeb71a7a8575e46aa04087af01a3d9e1abfb")),

		// Sugary extensions for the SwiftNIO library
		.package(url: "https://github.com/vapor/async-kit.git", from: "1.3.0"),

		// A simple multipart MIME encoder that supports form-data, files and nesting.
		.package(url: "https://github.com/LebJe/Multipart.git", .branch("master")),

		// 🗂 Swift MIME type checking based on magic bytes
		.package(url: "https://github.com/sendyhalim/Swime.git", from: "3.0.7"),

		// .package(url: "https://github.com/LebJe/CTabulate.git", .branch("main")),
	],
	targets: [
		.target(
			name: "ArcGISKit",
			dependencies: [
				"SwiftyJSON",
				"Multipart",
				"Swime",
				.product(name: "AsyncKit", package: "async-kit"),
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "CodableWrappers", package: "CodableWrappers"),
			]
		),
		.testTarget(
			name: "ArcGISKitTests",
			dependencies: ["ArcGISKit"]
		),
	]
)
