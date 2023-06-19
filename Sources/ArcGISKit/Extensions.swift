// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import Foundation
import GenericHTTPClient
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

extension GHCHTTPRequest {
	init(url: WebURL, method: GHCHTTPMethod = .GET, headers: GHCHTTPHeaders = [:], body: Self.HTTPBody? = nil) throws {
		try self.init(url: URL(string: url.serialized())!, method: method, headers: headers, body: body)
	}
}

/// Append a path component to `lhs`.
func + (lhs: WebURL, rhs: some StringProtocol) -> WebURL {
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
