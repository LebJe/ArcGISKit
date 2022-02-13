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
		// HTTP client library built on SwiftNIO
		.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.8.1"),

		// A Collection of PropertyWrappers to make custom Serialization of Swift Codable Types easy
		.package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", from: "2.0.6"),

		// For dealing with ambiguous JSON that doesn't connect to a specific type
		.package(url: "https://github.com/skelpo/json.git", from: "1.1.4"),

		// Build multipart/form-data type-safe in Swift.
		.package(url: "https://github.com/FelixHerrmann/swift-multipart-formdata.git", from: "1.0.1"),

		// Straightforward, type-safe argument parsing for Swift
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.2"),

		// JSON encoding and decoding without the use of Foundation in pure Swift.
		.package(url: "https://github.com/swift-extras/swift-extras-json.git", from: "0.6.0"),

		// Event-driven network application framework for high performance protocol servers & clients, non-blocking.
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.35.0"),

		.package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint.git", from: "1.2.0"),

		// A new URL type for Swift
		.package(url: "https://github.com/karwa/swift-url.git", from: "0.2.0"),

		// .package(url: "https://github.com/LebJe/CTabulate.git", .branch("main")),
	],
	targets: [
		.executableTarget(
			name: "ArcGISKitExample",
			dependencies: [
				"ArcGISKit",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: [
				.unsafeFlags([
					"-Xfrontend", "-disable-availability-checking",
				]),
			]
		),
		.target(
			name: "ArcGISKit",
			dependencies: [
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "CodableWrappers", package: "CodableWrappers"),
				.product(name: "ExtrasJSON", package: "swift-extras-json"),
				.product(name: "JSON", package: "JSON"),
				.product(name: "MultipartFormData", package: "swift-multipart-formdata"),
				.product(name: "NIOCore", package: "swift-nio"),
				.product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint"),
				.product(name: "WebURL", package: "swift-url"),
				// "Swime",
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-disable-availability-checking"]),
			]
		),
		.testTarget(
			name: "ArcGISKitTests",
			dependencies: ["ArcGISKit"],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-disable-availability-checking"]),
			]
		),
	]
)
