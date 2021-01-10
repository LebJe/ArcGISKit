//
//  Errors.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation

public enum RequestError: Error {
	/// A token is required. Login using a username and password so `GIS.init` can generate a token.
	case tokenRequired

	/// The username or password provided to `GIS.init` was invalid.
	case invalidUsernameOrPassword

	/// An unknown error occurred.
	case unknown(message: String)
}

struct ResponseError: Codable {
	let error: E
}

struct E: Codable {
	let code: Int
	let message: String
	let messageCode: String?
	let details: [String]
}
