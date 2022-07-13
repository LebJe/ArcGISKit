// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Date
import WebURL

///
public struct Paginated<T: Codable>: Codable {
	///  The total amount of `T`'s.
	public let total: Int
	public let start: Int
	public let num: Int
	public var nextStart: Int
	public var items: [T]
	public var folders: [Folder]?
}

///
public struct Paginator<T: Codable> {
	private var nextStart: Int = 0
	private var url: WebURL
	private var token: String? = nil
	private var client: AGKHTTPClient

	public var current: Paginated<T>? = nil

	public init(client: AGKHTTPClient, url: WebURL, token: String? = nil) {
		self.client = client
		self.url = url
		self.token = token
	}

	/// Retrieves the values from `self.nextStart` to `limit`.
	public mutating func advance(limit: Int = 100) async throws -> Bool {
		guard self.nextStart != -1 else { return false }

		self.url.formParams += [
			"f": "json",
			"start": String(self.nextStart),
			"num": String(limit),
		]

		if let t = token { self.url.formParams.token = t }

		let req = AGKHTTPRequest(url: self.url)
		let res = try handle(response: await self.client.send(request: req), decodeType: Paginated<T>.self)
		self.nextStart = res.nextStart
		self.current = res

		return true
	}
}

public struct Folder: Codable {
	public let id: String?
	public let title: String?
	public let username: String?
	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var created: Date?
}
