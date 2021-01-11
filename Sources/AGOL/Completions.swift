//
//  Completions.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation
import ArcGISKit

func groupCompletion() -> [String] {
	do {
		let gis = try getGIS()
		if let groups = gis.user?.groups {
			return groups.map({ $0.id ?? "" })
		}
	} catch {}
	return []
}

func userContentCompletion() -> [String] {
	do {
		var gis = try getGIS()
		if var user = gis.user {
			try user.fetchContent(from: gis)
			return user.content.map(
				{
					switch $0 {
						case .featureServer(featureServer: _, metadata: let m):
							return m.id ?? ""
					}
				}
			)
		}
	} catch {}
	return []
}
