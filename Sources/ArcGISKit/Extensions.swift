// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import Foundation
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

extension AGKHTTPRequest {
	init(url: WebURL, method: AGKHTTPMethod = .GET, headers: AGKHTTPHeaders = [:], body: Either<String, [UInt8]>? = nil) {
		self.url = URL(string: url.serialized())!
		self.method = method
		self.headers = headers
		if let body = body {
			switch body {
				case let .left(s):
					self.body = Array(s.utf8)
				case let .right(u):
					self.body = u
			}
		}
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

extension String {
	/// Initialize `String` from an array of bytes.
	init(_ bytes: [UInt8]) {
		self = String(bytes.map({ Character(Unicode.Scalar($0)) }))
	}
}
