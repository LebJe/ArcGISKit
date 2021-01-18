//
//  Responses.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import CodableWrappers

struct RequestTokenResponse: Codable {
	let token: String

	@Immutable @MillisecondsSince1970DateCoding
	var expires: Date
	let ssl: Bool
}

struct RequestOAuthTokenResponse: Codable {
	let accessToken: String

	@Immutable @MillisecondsSince1970DateCoding
	var expiresIn: Date
	
	let username: String?
	let ssl: Bool?
	let refreshToken: String?

	enum CodingKeys: String, CodingKey {
		case expiresIn = "expires_in"
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
		case username = "username"
		case ssl = "ssl"
	}
}
