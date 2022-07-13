// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArcGISKit

import Foundation

#if canImport(FoundationNetworking)
	import FoundationNetworking
#endif

public class URLSessionHTTPClient: AGKHTTPClient {
	private let urlSession: URLSession

	public init(session: URLSession = .shared) {
		self.urlSession = session
	}

	public func send(request: ArcGISKit.AGKHTTPRequest) async throws -> ArcGISKit.AGKHTTPResponse {
		try await withCheckedThrowingContinuation({ c in
			urlSession.dataTask(with: URLRequest(from: request), completionHandler: { data, urlResponse, error in
				if let error = error {
					c.resume(throwing: error)
				}
				let body: [UInt8]?

				if let d = data {
					body = Array(d)
				} else {
					body = nil
				}

				c.resume(returning: AGKHTTPResponse(from: urlResponse as! HTTPURLResponse, body: body))
			}).resume()
		})
	}

	public func shutdown() {}
}

extension URLRequest {
	init(from request: AGKHTTPRequest) {
		self.init(url: request.url)
		self.httpMethod = request.method.rawValue

		for (key, value) in request.headers {
			self.setValue(value, forHTTPHeaderField: key)
		}

		if let body = request.body {
			self.httpBody = Data(body)
		}
	}
}

extension AGKHTTPResponse {
	init(from response: HTTPURLResponse, body: [UInt8]? = nil) {
		let h = response.allHeaderFields.compactMap({ key, value -> (String, String)? in
			if let key = key as? String, let value = value as? String {
				return (key, value)
			} else {
				return nil
			}
		})

		self.init(headers: .init(h), statusCode: response.statusCode, body: body)
	}
}
