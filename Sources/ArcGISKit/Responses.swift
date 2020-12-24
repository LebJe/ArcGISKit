//
//  Responses.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation

struct RequestTokenResponse: Codable {
	let token: String
	let expires: Int
	let ssl: Bool
}
