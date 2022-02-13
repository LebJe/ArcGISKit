// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

public enum AGKAuthError: Error {
	/// You logged in anonymously using `GIS.init`. You must login using a username and password, or a client ID and secret.
	case isAnonymous

	/// The username or password provided to `GIS.init` was invalid.
	case invalidUsernameOrPassword
}

public enum AGKDataError: Error {
	/// The [mime type](https://en.wikipedia.org/wiki/Media_type) of the file provided isn't supported.
	case unknownMimeType
}

/// Errors encountered when making API requests.
public enum AGKRequestError: Error {
	/// A token is required. Login using a username and password, or a client ID and secret so `GIS.init` can generate a token.
	case tokenRequired

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
