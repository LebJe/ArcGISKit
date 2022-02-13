// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import AsyncHTTPClient
import Foundation
import NIO
import NIOCore
import NIOHTTP1
import WebURL

extension String {
	var urlQueryEncoded: Self {
		self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
	}
}

extension StringProtocol {
	func contains<S: StringProtocol>(oneOf strings: S...) -> Bool {
		for string in strings {
			if !self.contains(string) {
				return false
			}
		}

		return true
	}
}

extension HTTPClient.Request {
	init(url: WebURL, method: NIOHTTP1.HTTPMethod = .GET, headers: NIOHTTP1.HTTPHeaders = HTTPHeaders(), body: AsyncHTTPClient.HTTPClient.Body? = nil) throws {
		try self.init(url: url.serialized(), method: method, headers: headers, body: body)
	}
}

/// Append a path component to `lhs`.
func + <S: StringProtocol>(lhs: WebURL, rhs: S) -> WebURL {
	var url = lhs
	url.pathComponents += [rhs]
	return url
}

/// Append path components to `lhs`.
func + <C: Collection>(lhs: WebURL, rhs: C) -> WebURL where C.Element: StringProtocol {
	var url = lhs
	url.pathComponents += rhs
	return url
}
