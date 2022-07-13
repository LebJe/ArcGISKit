// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit
import AsyncHTTPClient
import NIOHTTP1

public class AHCHTTPClient: AGKHTTPClient {
	private let httpClient: HTTPClient

	public init(client: HTTPClient = .init(eventLoopGroupProvider: .createNew)) {
		self.httpClient = client
	}

	public func send(request: AGKHTTPRequest) async throws -> AGKHTTPResponse {
		let req = try HTTPClient.Request(from: request)
		return AGKHTTPResponse(from: try await self.httpClient.execute(request: req).get())
	}

	public func shutdown() {
		self.httpClient.shutdown({ _ in })
	}
}

extension HTTPClient.Request {
	init(from request: AGKHTTPRequest) throws {
		try self.init(url: request.url, method: .init(from: request.method), headers: HTTPHeaders(request.headers.map({ ($0, $1) })))
		if let b = request.body {
			self.body = .bytes(b)
		}
	}
}

extension HTTPMethod {
	init(from method: AGKHTTPMethod) {
		switch method {
			case .GET: self = .GET
			case .PUT: self = .PUT
			case .HEAD: self = .HEAD
			case .POST: self = .POST
			case .DELETE: self = .DELETE
			case .OPTIONS: self = .OPTIONS
			default: self = .GET
		}
	}
}

extension AGKHTTPResponse {
	init(from response: HTTPClient.Response) {
		let body: [UInt8]?

		if let b = response.body {
			body = Array(buffer: b)
		} else {
			body = nil
		}

		self.init(headers: .init(response.headers.map({ ($0, $1) })), statusCode: Int(response.status.code), body: body)
	}
}
