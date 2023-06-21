// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import enum GenericHTTPClient.GHCError

public enum AGKError: Error {
	case authError(AGKAuthError)
	case dataError(AGKDataError)
	case requestError(AGKRequestError)
}

public enum AGKAuthError: Error {
	/// You logged in anonymously using `GIS.init`. You must login using a username and password, or a client ID and
	/// secret.
	case isAnonymous

	/// The username or password provided to `GIS.init` was invalid.
	case invalidUsernameOrPassword

	/// A token is required. Login using a username and password, or a client ID and secret so `GIS.init` can generate a
	/// token.
	case tokenRequired
}

public enum AGKDataError: Error {
	/// The [mime type](https://en.wikipedia.org/wiki/Media_type) of the file provided isn't supported.
	case unknownMimeType
}

/// Errors encountered when making API requests.
public enum AGKRequestError: Error {
	case clientError(GHCError)

	/// The filename could not be [percent-encoded](https://en.wikipedia.org/wiki/URL_encoding) (for uploading in a
	/// [multipart](https://en.wikipedia.org/wiki/MIME#Multipart_messages) request)
	case invalidFilename(name: String)

	case encodingError(EncodingError)

	case decodingError(DecodingError, rawJSON: String)

	case other(Error)

	/// JSON data was expected in the response, but none was provided.
	case noResponse

	/// The ArcGIS API returned an error response.
	case unknown(code: Int?, message: String?, details: [String]?)
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
