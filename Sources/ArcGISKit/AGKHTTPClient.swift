// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import struct Foundation.URL

public protocol AGKHTTPClient {
	func send(request: AGKHTTPRequest) async throws -> AGKHTTPResponse
	func shutdown()
}

public struct AGKHTTPRequest {
	public var url: URL
	public var method: AGKHTTPMethod
	public var headers: AGKHTTPHeaders = [:]
	public var body: [UInt8]?

	public init(url: URL, method: AGKHTTPMethod = .GET, headers: AGKHTTPHeaders = [:], body: Either<String, [UInt8]>? = nil) {
		self.url = url
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

public struct AGKHTTPHeaders: ExpressibleByDictionaryLiteral, Sequence {
	public typealias Key = String

	public typealias Value = String

	public var headers: [(String, String)] = []

	public init(dictionaryLiteral elements: (String, String)...) {
		self.headers = elements
	}

	public init(dictionary: [String: String]) {
		self.headers = dictionary.map({ ($0, $1) })
	}

	public init(_ elements: [(String, String)]) {
		self.headers = elements
	}

	public subscript(key: String) -> String? {
		for (k, v) in headers {
			if k == key {
				return v
			}
		}

		return nil
	}

	public func makeIterator() -> AGKHTTPHeadersIterator {
		AGKHTTPHeadersIterator(headers: self.headers)
	}
}

public struct AGKHTTPHeadersIterator: Sequence, IteratorProtocol {
	private var index: Int = 0
	private var headers: [(String, String)]

	public typealias Element = (key: String, value: String)

	init(headers: [(String, String)]) {
		self.headers = headers
	}

	public mutating func next() -> (key: String, value: String)? {
		guard !headers.isEmpty else { return nil }
		guard headers.count - 1 >= self.index else { return nil }
		let value = self.headers[self.index]
		self.index += 1
		return value
	}
}

public struct AGKHTTPResponse {
	public var headers: AGKHTTPHeaders
	public var body: [UInt8]?
	public var statusCode: Int

	public init(headers: AGKHTTPHeaders, statusCode: Int, body: [UInt8]? = nil) {
		self.headers = headers
		self.statusCode = statusCode
		self.body = body
	}
}

public enum AGKHTTPMethod: String {
	case GET
	case POST
	case PUT
	case PATCH
	case HEAD
	case DELETE
	case OPTIONS
}
