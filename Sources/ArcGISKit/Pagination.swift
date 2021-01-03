//
//  Pagination.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

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

}
