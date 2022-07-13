// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ExtrasJSON

func handle<T: Decodable>(response: AGKHTTPResponse, decodeType: T.Type) throws -> T {
	if response.body != nil {
		do {
			return try XJSONDecoder().decode(decodeType, from: response.body!)
		} catch {
			do {
				let re = try XJSONDecoder().decode(ResponseError.self, from: response.body!)

				throw AGKRequestError.unknown(message: re.error?.message, details: re.error?.details)

				// switch re.error?.message.lowercased() ?? "" {
				// 	case "Invalid username or password.".lowercased():
				// 		throw AGKAuthError.invalidUsernameOrPassword
				// 	case "Token Required".lowercased():
				// 		throw AGKRequestError.tokenRequired
				// 	case "Unable to generate token.".lowercased():
				// 		if let details = re.error?.details {
				// 			if details.contains("Invalid username or password.") {
				// 				throw AGKAuthError.invalidUsernameOrPassword
				// 			} else {
				// 				throw AGKRequestError.unknown(message: re.error?.message, details: re.error?.details)
				// 			}
				// 		} else {
				// 			throw AGKRequestError.unknown(message: re.error?.message, details: re.error?.details)
				// 		}
				// 	default:
				// 		throw AGKRequestError.unknown(message: re.error?.message, details: re.error?.details)
				// }
			} catch {
				throw error
			}
		}
	} else {
		throw AGKRequestError.unknown(message: "No response", details: nil)
	}
}
