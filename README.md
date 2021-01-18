# ArcGISKit

**Under Construction! DO NOT USE!**

**A Swift library and CLI for the [ArcGIS REST API](https://developers.arcgis.com/rest/).**

[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey](https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey)](https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey)
[![](https://img.shields.io/github/v/tag/LebJe/ArcGISKit)](https://github.com/LebJe/ArcGISKit/releases)
[![Build and Test](https://github.com/LebJe/ArcGISKit/workflows/Build%20and%20Test/badge.svg)](https://github.com/LebJe/ArcGISKit/actions?query=workflow%3A%22Build+and+Test%22)

Documentation comments are taken from the [ArcGIS REST API](https://developers.arcgis.com/rest/).

View the documentation on [Github Pages](https://lebje.github.io/ArcGISKit/).


**Under Construction! DO NOT READ!**

## Install
### Swift Package Manager
Add this to the `dependencies` array in `Package.swift`:

```swift
.package(url: "https://github.com/LebJe/ArcGISKit", from: "1.0.0")
```

And add this to the `targets` array in the aforementioned file:

```swift
.product(name: "ArcGISKit", package: "ArcGISKit")
```

## Usage

You first need to get a `GIS`:

```swift
import ArcGISKit
import NIO

// Setup a group for the `HTTPClient`.
let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

// Login using a username and password.
let authenticatedGIS = GIS(
authType: .credentials(username: "username", password: "password"), 
eventLoopGroup: group, 
url: URL(string: "https://my-organization.maps.arcgis.com")!
)

let user = try authenticatedGIS.fetchUser().wait()

// Login anonymously.
// There is no user available since we logged in anonymously.
let anonymousGIS = GIS(authType: .anonymous, eventLoopGroup: group)

// Login using a client ID and client secret.
let idAndSecretGIS = GIS(
authType: .idAndSecret(clientID: "id", clientSecret: "secret", username: "username"),
eventLoopGroup: group,
url: URL(string: "https://my-organization.maps.arcgis.com")!
```

Once you have a `GIS` you can fetch a `User`:

```swift
var gis: GIS = ...

// Fetch synchronously.
let user = try gis.fetchUser().wait()

// Fetch asynchronously.
try gis.fetchUser().whenComplete({ res in
	switch res {
		case .failure(let error):
		// something went wrong...
		break
		case .success(let user):
		// Use `user` here.
		print(user)
	}
})
```
