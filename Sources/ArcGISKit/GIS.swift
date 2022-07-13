// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import struct Foundation.Date
import struct Foundation.URL
import WebURL

public final actor GIS {
	// MARK: - Public properties.

	/// The URL used to access the `User`'s ArcGIS Online organization, ArcGIS Enterprise installation, et cetera.
	public let url: WebURL

	/// The username of the current `User`, if logged in.
	public let username: String?

	/// The password of the current `User`, if logged in.
	public let password: String?

	public let authType: AuthenticationType

	public var isAnonymous: Bool { self.authType == .anonymous && (self.username == nil && self.password == nil) }

	/// The token for the logged in `User`.
	public var currentToken: String?

	/// The token that is used to refresh `self.currentToken`.
	public var refreshToken: String?

	/// The `Date` when `self.currentToken` will expire.
	public var tokenExpirationDate: Date?

	/// If `self.currentToken` expired.
	public var tokenExpired: Bool {
		if let eDate = self.tokenExpirationDate {
			return eDate.timeIntervalSince1970 < Date().timeIntervalSince1970
		}
		return true
	}

	/// Retrieves the ``User`` that provided their credentials via ``GIS.init``.
	/// - Throws: `AGKRequestError`.
	/// - Reference: [https://developers.arcgis.com/rest/users-groups-and-items/user.htm](https://developers.arcgis.com/rest/users-groups-and-items/user.htm)
	public var user: User {
		get async throws {
			guard !self.isAnonymous else { throw AGKAuthError.isAnonymous }

			var newURL = self.fullURL + ["community", "users", self.username!]

			newURL.formParams.token = self.currentToken!
			newURL.formParams.f = "json"

			let req = AGKHTTPRequest(url: newURL, method: .POST)

			// TODO: Fix.
			return try await handle(response: self.httpClient.send(request: req), decodeType: User.self)
		}
	}

	// MARK: - Private properties.

	let httpClient: AGKHTTPClient
	var fullURL: WebURL { self.url + self.site }
	let site: String

	/// Creates an instance using `authType` to authenticate to ArcGIS Online.
	///
	/// - Parameters:
	///   - authType: The method of authentication you wish to use.
	///   - eventLoopGroup: The `EventLoopGroup` needed for the `HTTPClient`.
	///   - url: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	/// - Throws: `AGKRequestError`
	///
	/// If `authType` is ``AuthenticationType.webBrowser``, You must first call ``GIS.generateURL(clientID:baseURL:site:)`` (without changing `redirectURI`) to generate a `URL`.
	/// Direct the user of your app to go to that `URL`, login to ArcGIS Online, then copy and paste the returned code back into your app.
	/// Once you receive the code, you can then pass it to this initializer.
	public init(
		authentication authType: AuthenticationType,
		url: URL = URL(string: "https://arcgis.com")!,
		site: String = "sharing",
		client: AGKHTTPClient
	) async throws {
		self.url = WebURL(url.absoluteString)!
		self.site = site
		self.httpClient = client

		switch authType {
			case let .credentials(username: username, password: password):
				self.authType = authType
				self.username = username
				self.password = password
				try await self.fetchToken()
			case .anonymous:
				self.authType = authType
				self.currentToken = nil
				self.username = nil
				self.password = nil
			case let .idAndSecret(clientID: _, clientSecret: _, username: u):
				self.authType = authType
				self.currentToken = nil
				self.username = u
				self.password = nil
				try await self.fetchToken()
			case .webBrowser:
				fatalError("Web browser authentication is not implemented yet.")
//				self.authType = authType
//				self.username = nil
//				self.password = nil
		}
	}

	deinit { self.httpClient.shutdown() }

	/// Requests a token and saves it in `self.currentToken`.
	public func fetchToken() async throws {
		guard !self.isAnonymous else {
			throw AGKAuthError.isAnonymous
		}

		// TODO: Use `self.refreshToken` if it is not nil.

		if case let .idAndSecret(clientID: cI, clientSecret: cS, username: _) = self.authType {
			var newURL = self.fullURL + ["rest", "oauth2", "token"]
			newURL.formParams += [
				"f": "json",
				"grant_type": "client_credentials",
				"client_id": cI,
				"client_secret": cS,
			]

			let req = AGKHTTPRequest(url: url)

			let res = try handle(response: try await self.httpClient.send(request: req), decodeType: RequestOAuthTokenResponse.self)

			self.refreshToken = res.refreshToken
			self.tokenExpirationDate = res.expiresIn
			self.currentToken = res.accessToken

		} else {
			var newURL: WebURL

			var infoURL = self.fullURL + ["rest", "info"]
			infoURL.formParams += ["f": "json"]

			if let tokenURLString = try await handle(
				response: self.httpClient.send(request: AGKHTTPRequest(url: infoURL)),
				decodeType: ServerInfo.self
			).authInfo?.tokenServicesUrl, let tokenURL = WebURL(tokenURLString) {
				if let tokenURLHost = tokenURL.host, let baseURLHost = self.url.host, tokenURLHost.serialized != baseURLHost.serialized {
					newURL = self.fullURL + ["rest", "generateToken"]
				}
				newURL = tokenURL
			} else {
				newURL = self.fullURL + ["rest", "generateToken"]
			}

			let req = AGKHTTPRequest(
				url: newURL,
				method: .POST,
				headers: ["Content-Type": "application/x-www-form-urlencoded"],
				body: .left(
					"f=json&username=\(self.username!.urlQueryEncoded)&password=\(self.password!.urlQueryEncoded)&client=referer&referer=\("https://arcgis.com".urlQueryEncoded)"
				)
			)

			let res = try handle(response: await self.httpClient.send(request: req), decodeType: RequestTokenResponse.self)

			self.tokenExpirationDate = res.expires
			self.currentToken = res.token
		}
	}

	/// Generates a `URL` that users of your app should go to to authenticate. Once they authenticate, they should copy and paste the authentication code back into your app; that code can then be passed to `GIS.init`.
	/// - Parameters:
	///   - clientID:
	///   - baseURL: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	///   - redirectURI: The `URL` that will receive a code once the user has logged in. Use the default ("urn:ietf:wg:oauth:2.0:oob") to have ArcGIS Online present the code to the user instead of redirecting to a different `URL`.
	/// - Returns: The generated `URL`.
	public static func generateURL(
		clientID: String,
		baseURL: URL = URL(string: "https://arcgis.com")!,
		site: String = "sharing",
		redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
	) -> URL {
		var u = WebURL(baseURL.absoluteString)! + [site, "rest", "oauth2", "authorize"]

		u.formParams += [
			"response_type": "code",
			"client_id": clientID,
			"redirect_uri": redirectURI,
		]

		return URL(string: u.serialized())!
	}
}

///// Retrieves the content owned by a `User`, in a `Group`, etc.
///// - Parameters:
/////   - client: The client used to make HTTP requests.
/////   - token: The token used to authenticate.
/////   - url: Where the content is located.
/////   - start: See [Paging Parameters](https://developers.arcgis.com/rest/users-groups-and-items/common-parameters.htm#ESRI_SECTION1_42D43ABF38FC49F8B9DC6A9BFEA1E235) for more information.
/////   - limit: See [Paging Parameters](https://developers.arcgis.com/rest/users-groups-and-items/common-parameters.htm#ESRI_SECTION1_42D43ABF38FC49F8B9DC6A9BFEA1E235) for more information.
/////   - The type that will be retrieved from `url`.
// func getContent<T: Codable>(
//	client: HTTPClient,
//	token: String? = nil,
//	url: URL,
//	start: Int = 1,
//	limit: Int = 100,
//	decodeType: T.Type
// ) async throws -> [T] {
//	let req = try HTTPClient.Request(url: "\(url.absoluteString)?&f=json&start=\(start)&num=\(limit)\(token != nil ? "&token=\(token!)" : "")", method: .GET)
//	return try handle(response: try await client.execute(request: req).get(), decodeType: Paginated<T>.self).items
// }

struct ServerInfo: Decodable {
	var authInfo: AuthInfo? = nil

	struct AuthInfo: Decodable {
		var tokenServicesUrl: String? = nil
		var isTokenBasedSecurity: Bool? = nil
	}
}
