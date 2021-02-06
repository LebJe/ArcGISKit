import AsyncHTTPClient
import Foundation
import NIO

public class GIS {
	// MARK: - Public properties.

	public let url: URL
	public let username: String?
	public let password: String?
	public let authType: AuthenticationType
	public var isAnonymous: Bool { self.authType == .anonymous && (self.username == nil && self.password == nil) }

	// MARK: - Private properties.

	let client: HTTPClient
	let eventLoopGroup: EventLoopGroup
	var fullURL: URL { self.url.appendingPathComponent(self.site) }
	let site: String
	var token: String?
	var refeshToken: String?

	/// Creates an instance using `authType` to authenticate to ArcGIS Online.
	///
	/// If `authType` is `.webBrowser`, You must first call `GIS.generateURL(clientID:, baseURL:, site:)` (without changing `redirectURI`)  to generate a `URL`.
	/// Direct the user of your app to go to that `URL`, login to ArcGIS Online, then to copy and paste the returned code back into your app.
	/// Once you receive the code, you can then pass it to this initializer.
	///
	/// - Parameters:
	///   - authType: The method of authentication you wish to use.
	///   - eventLoopGroup: The `EventLoopGroup` needed for the `HTTPClient`.
	///   - url: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	/// - Throws: `AGKRequestError`.
	public init(_ authType: AuthenticationType, eventLoopGroup: EventLoopGroup, url: URL = URL(string: "https://arcgis.com")!, site: String = "sharing") {
		self.url = url
		self.site = site
		self.eventLoopGroup = eventLoopGroup
		self.client = HTTPClient(eventLoopGroupProvider: .shared(self.eventLoopGroup), configuration: .init(redirectConfiguration: .follow(max: 10, allowCycles: false)))

		switch authType {
			case let .credentials(username: username, password: password):
				self.authType = authType
				self.username = username
				self.password = password
			case .anonymous:
				self.authType = authType
				self.token = nil
				self.username = nil
				self.password = nil
			case let .idAndSecret(clientID: _, clientSecret: _, username: u):
				self.authType = authType
				self.token = nil
				self.username = u
				self.password = nil
			case .webBrowser:
				fatalError("Web browser authentication is not implemented yet.")
//				self.authType = authType
//				self.username = nil
//				self.password = nil
		}
	}

	deinit {
		self.client.shutdown({ _ in })
	}

	/// Validate the credentials passed to `GIS.init`.
	///
	/// If you logged in anonymously, this method will throw `AGKAuthError.isAnonymous`.
	///
	/// - Throws: `AGKAuthError`.
	/// - Returns: A `EventLoopFuture` indicating the task has completed.
	public func checkCredentials() throws -> EventLoopFuture<Void> {
		if self.isAnonymous { throw AGKAuthError.isAnonymous }

		return try self.fetchToken()
	}

	func fetchToken() throws -> EventLoopFuture<Void> {
		if self.isAnonymous {
			throw AGKAuthError.isAnonymous
		}

		if case let .idAndSecret(clientID: cI, clientSecret: cS, username: _) = self.authType {
			let newURL = self.fullURL
				.appendingPathComponent("rest")
				.appendingPathComponent("oauth2")
				.appendingPathComponent("token")

			let req = try HTTPClient.Request(
				url: "\(newURL.absoluteString)?f=json&grant_type=client_credentials&client_id=\(cI.urlQueryEncoded)&client_secret=\(cS.urlQueryEncoded)",
				method: .GET
			)

			return self.client.execute(request: req).flatMapThrowing({ res in
				try handle(response: res, decodeType: RequestOAuthTokenResponse.self)
			})
				.flatMapThrowing({
					self.token = $0.accessToken
					self.refeshToken = $0.refreshToken
				})

		} else {
			let newURL = self.url.appendingPathComponent(self.site).appendingPathComponent("rest").appendingPathComponent("generateToken")

			let req = try HTTPClient.Request(
				url: "\(newURL.absoluteString)?f=json&username=\(username!.urlQueryEncoded)&password=\(self.password!.urlQueryEncoded)&referer=\("https://arcgis.com".urlQueryEncoded)",
				method: .POST
			)

			return self.client.execute(request: req).flatMapThrowing({ res in
				try handle(response: res, decodeType: RequestTokenResponse.self)
			})
				.flatMapThrowing({
					self.token = $0.token
				})
		}
	}

	/// Retrieves the `User` that provided their credentials via `GIS.init`.
	/// - Throws: `AGKRequestError`.
	/// - Returns: The retrieved `User`.
	public func fetchUser() throws -> EventLoopFuture<User> {
		if self.isAnonymous {
			throw AGKAuthError.isAnonymous
		}

		return try self.fetchToken()
			.flatMap({ _ in
				let newURL = self.fullURL
					.appendingPathComponent("community")
					.appendingPathComponent("users")
					.appendingPathComponent(self.username!)
				let req = try! HTTPClient.Request(
					url: "\(newURL.absoluteString)?f=json&token=\(self.token!.urlQueryEncoded)",
					method: .POST
				)

				return self.client.execute(request: req)
					.map({
						// TODO: Fix.
						try! handle(response: $0, decodeType: User.self)
					})
			})
	}

	/// Generates a `URL` that users of your app should go to to authenticate. Once they authenticate, they should copy and paste the authentication code back into your app; that code can then be passed to `GIS.init`.
	/// - Parameters:
	///   - clientID:
	///   - baseURL: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	///   - redirectURI: The `URL` that will receive a code once the user has logged in. Use the default ("urn:ietf:wg:oauth:2.0:oob") to have ArcGIS Online present the code to the user instead of redirecting to a different `URL`.
	/// - Returns: The generated `URL`.
	public static func generateURL(clientID: String, baseURL: URL = URL(string: "https://arcgis.com")!, site: String = "sharing", redirectURI: String = "urn:ietf:wg:oauth:2.0:oob") -> URL {
		let u = baseURL
			.appendingPathComponent(site)
			.appendingPathComponent("rest")
			.appendingPathComponent("oauth2")
			.appendingPathComponent("authorize")
		return URL(string: "\(u.absoluteString)?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI.urlQueryEncoded)")!
	}
}

func getContent<T: Codable>(client: HTTPClient, token: String, url: URL, decodeType: T.Type) throws -> EventLoopFuture<[T]> {
	let req = try HTTPClient.Request(url: "\(url.absoluteString)?token=\(token)&f=json&start=1&num=100", method: .GET)

	return client.execute(request: req).flatMapThrowing({
		try handle(response: $0, decodeType: Pagination<T>.self).items
	})
}
