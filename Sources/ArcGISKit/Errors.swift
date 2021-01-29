//
//  Errors.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation

public enum AGKAuthError: Error {
	case isAnonymous
}

public enum AGKDataError: Error {
	/// The [mime type](https://en.wikipedia.org/wiki/Media_type) of the file provided isn't supported.
	case unknownMimeType
}

/// Errors encountered when making API requests.
public enum AGKRequestError: Error {
	/// A token is required. Login using a username and password so `GIS.init` can generate a token.
	case tokenRequired

	/// The username or password provided to `GIS.init` was invalid.
	case invalidUsernameOrPassword

	/// An unknown error occurred.
	case unknown(message: String?, details: [String]?)
}

struct ResponseError: Codable {
	let error: E?
}

struct E: Codable {
	let code: Int
	let message: String
	let messageCode: String?
	let details: [String]
}
