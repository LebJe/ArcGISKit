//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import AsyncHTTPClient

class GS {
	let client: HTTPClient
	init() {
		self.client = HTTPClient(eventLoopGroupProvider: .createNew, configuration: .init(redirectConfiguration: .follow(max: 10, allowCycles: false)))
	}

	deinit {
		do {
			try client.syncShutdown()
		} catch {

		}
	}
}

let gs = GS()
