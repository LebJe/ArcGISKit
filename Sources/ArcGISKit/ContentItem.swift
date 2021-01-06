//
//  ContentItem.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

import Foundation
import CodableWrappers

public struct ContentItem: Codable, Equatable {
	let id: String?
	let item: String?
	let itemType: String?
	let owner: String?

	@Immutable @MillisecondsSince1970DateCoding
	var uploaded: Date

	@Immutable @MillisecondsSince1970DateCoding
	var modified: Date
	
	let isOrgItem: Bool?
	let guid: String?
	let name: String?
	let title: String?
	let type: String?
}
