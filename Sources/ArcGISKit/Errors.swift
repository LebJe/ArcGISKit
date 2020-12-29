//
//  Errors.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation

public enum GISError: Error {
	/// `GIS.refreshToken` failed. All API requests will fail due to the token being invalid.
	case refreshTokenFailed
	/// The username or password provided to `GIS.init` was invalid.
	case invalidUsernameOrPassword

	case fetchTokenFailed
}
