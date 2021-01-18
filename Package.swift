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
		)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.2"),
		.package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", .upToNextMajor(from: "2.0.0")),
		.package(url: "https://github.com/mlilback/SwiftyJSON.git", .revision("5bcfbeb71a7a8575e46aa04087af01a3d9e1abfb")),
		//.package(url: "https://github.com/LebJe/CTabulate.git", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(name: "Echo", path: "Sources/Echo"),
		
        .target(
            name: "ArcGISKit",
            dependencies: [
				"SwiftyJSON",
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "CodableWrappers", package: "CodableWrappers"),
			]
		),
        .testTarget(
            name: "ArcGISKitTests",
            dependencies: ["ArcGISKit"]),
    ]
)
