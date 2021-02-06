//
//  authenticate.swift
//
//
//  Created by Jeff Lebrun on 2/6/21.
//

import ArcGISKit
import struct Foundation.URL

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

func authenticate(username: String, password: String, url: URL) throws -> GIS {
	let gis = GIS(.credentials(username: username, password: password), eventLoopGroup: group, url: url)
	try gis.checkCredentials().wait()
	return gis
}
