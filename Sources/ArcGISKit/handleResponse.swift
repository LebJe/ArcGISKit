//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation
import AsyncHTTPClient

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
						throw RequestError.invalidUsernameOrPassword
					case "Token Required".lowercased():
						throw RequestError.tokenRequired
					default:
						throw RequestError.unknown(message: re.error?.message)
				}
			} catch {
				throw error
			}
		}
	} else {
		throw RequestError.unknown(message: "No response")
	}
}
