//
//  Pagination.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

import CodableWrappers
import Foundation

struct Pagination<T: Codable>: Codable {
	let total: Int
	let start: Int
	let num: Int
	let nextStart: Int
	let items: [T]
	let folders: [Folder]?
}

struct Folder: Codable {
	let id: String?
	let title: String?
	let username: String?
	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	var created: Date?
	
}
