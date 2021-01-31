//
//  File.swift
//
//
//  Created by Jeff Lebrun on 1/10/21.
//

import class AsyncHTTPClient.HTTPClient
import struct Foundation.Data
import class Foundation.JSONDecoder

func handle<T: Codable>(response: HTTPClient.Response, decodeType: T.Type) throws -> T {
	if response.body != nil {
		do {
			let t = try JSONDecoder().decode(decodeType, from: Data(buffer: response.body!))
			return t
		} catch {
			do {
				let re = try JSONDecoder().decode(ResponseError.self, from: Data(buffer: response.body!))

				switch re.error?.message.lowercased() ?? "" {
					case "Invalid username or password.".lowercased():
						throw AGKRequestError.invalidUsernameOrPassword
					case "Token Required".lowercased():
						throw AGKRequestError.tokenRequired
					default:
						throw AGKRequestError.unknown(message: re.error?.message, details: re.error?.details)
				}
			} catch {
				throw error
			}
		}
	} else {
		throw AGKRequestError.unknown(message: "No response", details: nil)
	}
}
