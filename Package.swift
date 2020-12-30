// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArcGISKit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ArcGISKit",
            targets: ["ArcGISKit"]
		),
		.executable(name: "agol", targets: ["AGOL"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.2"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.1"),
		.package(url: "https://github.com/onevcat/Rainbow.git", from: "3.2.0"),
		.package(url: "https://github.com/JohnSundell/Files.git", from: "4.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(name: "Echo", path: "Sources/Echo"),
        .target(
            name: "ArcGISKit",
            dependencies: [
				.product(name: "AsyncHTTPClient", package: "async-http-client")
			]
		),
		.target(
			name: "AGOL",
			dependencies: [
				"ArcGISKit",
				"Echo",
				"Rainbow",
				"Files",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
        .testTarget(
            name: "ArcGISKitTests",
            dependencies: ["ArcGISKit"]),
    ]
)
