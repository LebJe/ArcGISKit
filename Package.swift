// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "ArcGISKit",
	platforms: [
		.macOS(.v11), .iOS(.v15),
	],
	products: [
		.executable(name: "examples", targets: ["ArcGISKitExample"]),
		.library(
			name: "ArcGISKit",
			targets: ["ArcGISKit"]
		),
	],
	dependencies: [
		// A Collection of PropertyWrappers to make custom Serialization of Swift Codable Types easy
		.package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", from: "2.0.6"),

		// For dealing with ambiguous JSON that doesn't connect to a specific type
		.package(url: "https://github.com/skelpo/json.git", from: "1.1.4"),

		// Build multipart/form-data type-safe in Swift.
		.package(url: "https://github.com/FelixHerrmann/swift-multipart-formdata.git", from: "1.0.1"),

		// Straightforward, type-safe argument parsing for Swift
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.3"),

		// JSON encoding and decoding without the use of Foundation in pure Swift.
		.package(url: "https://github.com/swift-extras/swift-extras-json.git", from: "0.6.0"),

		// A new URL type for Swift
		.package(url: "https://github.com/karwa/swift-url.git", from: "0.3.0"),

		.package(url: "https://github.com/LebJe/GenericHTTPClient.git", branch: "main"),

		// .package(url: "https://github.com/LebJe/CTabulate.git", .branch("main")),
	],
	targets: [
		.executableTarget(
			name: "ArcGISKitExample",
			dependencies: [
				"ArcGISKit",
				.product(name: "GHCAsyncHTTPClient", package: "GenericHTTPClient"),
				.product(name: "GHCURLSession", package: "GenericHTTPClient"),
				.product(name: "GenericHTTPClient", package: "GenericHTTPClient"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.target(
			name: "ArcGISKit",
			dependencies: [
				.product(name: "CodableWrappers", package: "CodableWrappers"),
				.product(name: "ExtrasJSON", package: "swift-extras-json"),
				.product(name: "JSON", package: "JSON"),
				.product(name: "GenericHTTPClient", package: "GenericHTTPClient"),
				.product(name: "MultipartFormData", package: "swift-multipart-formdata"),
				.product(name: "WebURL", package: "swift-url"),
			]
		),
		.testTarget(
			name: "ArcGISKitTests",
			dependencies: [
				"ArcGISKit",
				.product(name: "GHCAsyncHTTPClient", package: "GenericHTTPClient"),
			]
		),
	]
)
