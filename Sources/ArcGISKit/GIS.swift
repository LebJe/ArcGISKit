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

	/// Creates an instance containing a `username` and `password`, then requests a token for authentication.
	/// if `username` and `password` is `nil`, you will be logged in to ArcGIS Online anonymously.
	/// - Parameters:
	///   - url: Your ArcGIS Server hostname.
	///   - username: Your ArcGIS username.
	///   - password: Your ArcGIS password.
	///   - site: Your ArcGIS Server site name. The default is "sharing".
	public init(username: String? = nil, password: String? = nil, url: URL = URL(string: "https://arcgis.com")!, site: String = "sharing") throws {
		self.url = url
		self.username = username
		self.password = password
		self.site = site

		let newURL = url.appendingPathComponent(site).appendingPathComponent("rest").appendingPathComponent("generateToken")
		var token = ""

		if username != nil || password != nil {
			do {
				let req = try HTTPClient.Request(
					url: "\(newURL.absoluteString)?f=json&username=\(username!.urlQueryEncoded)&password=\(password!.urlQueryEncoded)&referer=\("https://arcgis.com".urlQueryEncoded)",
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
			getUser()
		} else {
			self.token = nil
		}
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
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .millisecondsSince1970
					let user = try decoder.decode(User.self, from: Data(buffer: res.body!))
					self.user = user
				}

			} catch {
				print(error)
			}
		}
	}
}


func getContent<T: Codable>(token: String, url: URL, decodeType: T.Type) throws -> [T] {
	let cReq = try HTTPClient.Request(url: "\(url.absoluteString)?token=\(token)&f=json&start=1&num=100", method: .GET)

	let res = try gs.client.execute(request: cReq).wait()

	if res.body != nil {
		if res.status == .ok {
			//print(String(data: Data(buffer: res.body!), encoding: .utf8)!)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970

			let pagination = try decoder.decode(Pagination<T>.self, from: Data(buffer: res.body!))
			//print(pagination.items)

			return pagination.items
		}
	}

	return []
}
