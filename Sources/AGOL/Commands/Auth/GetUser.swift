//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/28/20.
//

import Foundation
import ArcGISKit
import NIO

func getGIS() throws -> GIS {
	let agolC = try getConfigFileData()

	return try GIS(
		authType: agolC.username == nil && agolC.password == nil ? .anonymous : .credentials(username: agolC.username!, password: agolC.password!),
		url: agolC.url,
		site: agolC.site
	)
}
