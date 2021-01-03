//
//  ContentItem.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

import Foundation

public struct ContentItem: Codable, Equatable {
	let id: String?
	let item: String?
	let itemType: String?
	let owner: String?
	let uploaded: Date?
	let modified: Date?
	let isOrgItem: Bool?
	let guid: String?
	let name: String?
	let title: String?
	let type: String?
}
