import AsyncHTTPClient
import Foundation

public struct GIS {
	// MARK: - Public properties.
	public let url: URL
	public let username: String?
	public let password: String?
	public var user: User? = nil
	public var isAnonymous: Bool { user == nil }

	// MARK: - Private properties.
	var fullURL: URL { url.appendingPathComponent(site) }
	let site: String
	var token: String?

	/// Creates an instance using `authType` to authenticate to ArcGIS Online.
	/// - Parameters:
	///   - url: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	///   - authType: The method of authentication you wish to use.
	/// - Throws: `GISError`.
	public init(authType: AuthenticationType, url: URL = URL(string: "https://arcgis.com")!, site: String = "sharing") throws {
		self.url = url
		self.site = site

		switch authType {
			case let .credentials(username: username, password: password):
				self.username = username
				self.password = password

				let newURL = url.appendingPathComponent(site).appendingPathComponent("rest").appendingPathComponent("generateToken")
				var token = ""

				do {
					let req = try HTTPClient.Request(
						url: "\(newURL.absoluteString)?f=json&username=\(username.urlQueryEncoded)&password=\(password.urlQueryEncoded)&referer=\("https://arcgis.com".urlQueryEncoded)",
						method: .POST
					)

					let res = try gs.client.execute(request: req).wait()

					if res.body != nil {
						if res.status == .ok {
							do {
								let rtr = try JSONDecoder().decode(RequestTokenResponse.self, from: Data(buffer: res.body!))
								token = rtr.token
							} catch {
								let resString = String(data: Data(buffer: res.body!), encoding: .utf8) ?? ""

								if resString.contains("Invalid username or password.") {
									throw GISError.invalidUsernameOrPassword
								}
							}
						}
					}

				} catch {
					throw error
				}

				self.token = token
				self.getUser()

			case .anonymous:
				self.token = nil
				self.username = nil
				self.password = nil
			case .webBrowser:
				fatalError("Web Browser authentication is not implemented yet.")
//				self.username = nil
//				self.password = nil
		}
	}

	/// Generates a `URL` that users of your app should go to to authenticate. Once they authenticate, you they should copy and paste the authentication code back into your app; that code can then be passed to `GIS.init`.
	/// - Parameters:
	///   - clientID:
	///   - baseURL: Your ArcGIS Server hostname.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	/// - Returns: The generated `URL`.
	public static func url(clientID: String, baseURL: URL = URL(string: "https://arcgis.com")!, site: String = "sharing") -> URL {
		let u = baseURL
			.appendingPathComponent(site)
			.appendingPathComponent("rest")
			.appendingPathComponent("oauth2")
			.appendingPathComponent("authorize")
		return URL(string: "\(u.absoluteString)?response_type=code&client_id=\(clientID)&redirect_uri=\("urn:ietf:wg:oauth:2.0:oob".urlQueryEncoded)")!
	}

	/// Refresh the ArcGIS token.
	/// - Throws: `GISError`.
	mutating func refreshToken() throws {
		if username != nil || password != nil {
			do {
				let newURL = fullURL.appendingPathComponent("rest").appendingPathComponent("generateToken")
				let req = try! HTTPClient.Request(
					url: "\(newURL.absoluteString)?f=json&username=\(username!.urlQueryEncoded)&password=\(password!.urlQueryEncoded)&referer=\("https://arcgis.com".urlQueryEncoded)",
					method: .POST
				)

				let res = try gs.client.execute(request: req).wait()

				if res.status == .ok && res.body != nil {
					let rtr = try JSONDecoder().decode(RequestTokenResponse.self, from: Data(buffer: res.body!))
					self.token = rtr.token
				}
			} catch {
				throw GISError.refreshTokenFailed
			}
		}
	}

	mutating func getUser() {
		if username != nil || password != nil || token != nil {
			do {
				let newURL = fullURL.appendingPathComponent("community").appendingPathComponent("users").appendingPathComponent(username!)
				let req = try! HTTPClient.Request(
					url: "\(newURL.absoluteString)?f=json&token=\(token!.urlQueryEncoded)",
					method: .POST
				)

				let res = try gs.client.execute(request: req).wait()

				if res.status == .ok && res.body != nil {
					let user = try JSONDecoder().decode(User.self, from: Data(buffer: res.body!))
					self.user = user
				}

			} catch {
				print(error)
			}
		}
	}
}


func getContent<T: Codable>(token: String, url: URL, decodeType: T.Type) throws -> [T] {
	do {
		let cReq = try HTTPClient.Request(url: "\(url.absoluteString)?token=\(token)&f=json&start=1&num=100", method: .GET)

		let res = try gs.client.execute(request: cReq).wait()

		if res.body != nil {
			if res.status == .ok {
				let pagination = try JSONDecoder().decode(Pagination<T>.self, from: Data(buffer: res.body!))

				return pagination.items
			}
		}

		return []
	} catch {
		throw GISError.fetchContentFailed
	}
}
