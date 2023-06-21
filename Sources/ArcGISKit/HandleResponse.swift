// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ExtrasJSON
import GenericHTTPClient

// func send(request: GHCHTTPRequest, client: any GHCHTTPClient) -> Result<Void, GHCError> {

// }

func sendAndHandle<T: Decodable>(
	request: GHCHTTPRequest,
	client: any GHCHTTPClient,
	decodeType: T.Type
) async -> Result<T, AGKError> {
	let result = await client.send(request: request)

	switch result {
		case let .success(response):
			switch handle(response: response, decodeType: T.self) {
				case let .success(t): return .success(t)
				case let .failure(error): return .failure(.requestError(error))
			}
		case let .failure(error): return .failure(.requestError(.clientError(error)))
	}
}

func handle<T: Decodable>(response: GHCHTTPResponse, decodeType: T.Type) -> Result<T, AGKRequestError> {
	if response.body != nil {
		do {
			return try .success(XJSONDecoder().decode(decodeType, from: response.body!))
		} catch let error as DecodingError {
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

			do {
				let re = try XJSONDecoder().decode(ResponseError.self, from: response.body!)
				print(String(response.body!))
				return .failure(.unknown(code: re.error.code, message: re.error.message, details: re.error.details))
			} catch is DecodingError {
				return .failure(.decodingError(error, rawJSON: .init(response.body!)))
			} catch {
				return .failure(.other(error))
			}
		} catch {
			return .failure(.other(error))
		}
	} else {
		return .failure(.noResponse)
	}
}
