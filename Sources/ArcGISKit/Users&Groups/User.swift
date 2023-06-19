// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import Foundation
import GenericHTTPClient
import WebURL

/// A [User](https://developers.arcgis.com/rest/users-groups-and-items/user.htm) resource represents a registered user of the portal.
///
/// Personal details of the user, such as e-mail and groups, are returned only to the user or the administrator of the user's organization.
///
/// A user is not visible to any other user (except the organization's administrator) if their access setting is set to "private."
public struct User: Codable, Equatable {
	/// The ID of the user.
	public let id: String

	/// The user's first name.
	public let firstName: String?

	/// The user's last name.
	public let lastName: String?

	/// The user's full name.
	public var fullName: String?

	/// The username of the given user.
	public let username: String

	/// The original username if using enterprise logins.
	public var idpUsername: String?

	/// The user's e-mail address.
	public var email: String?

	/// A description of the user.
	public var description: String?

	/// User-defined tags that describe the user.
	public var tags: [String]?

	/// The number of credits available to the user.
	public let availableCredits: Double?

	/// The number of credits allocated to the user.
	public let assignedCredits: Double?

	/// The user's preferred view for content, either web or GIS.
	public var preferredView: String?

	/// Indicates the level of access of the user: private, org, or public.
	/// If `private`, the user descriptive information will not be available to others nor will the username be searchable.
	public var access: Access?

	/// Indicates if the user's account has multifactor authentication set up.
	public let mfaEnabled: Bool?

	/// The user's favorites group and is created automatically for each user.
	public let favGroupId: String?

	/// The last login date of the user.
	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var lastLogin: Date?

	/// The total storage used by the user's organization or subscription in Byte.
	public let storageUsage: Int?

	/// The total storage amount allowed for the user's organization or subscription in Byte. Usually 2TB for organization, 2GB for non-organization.
	public let storageQuota: Int?

	/// The ID of the organization the user belongs to.
	public let orgId: String?

	/// Defines the user's role in the organization.
	public let role: User.Role?

	/// An array of `Privilege`s for this `User`. For a complete listing, see [Privileges](https://developers.arcgis.com/rest/users-groups-and-items/privileges.htm#ESRI_SECTION2_3EAEA3BADD1446A68EA07F9F46F6690C).
	public let privileges: [String]?

	/// (Optional) The ID of the user's role if it is a custom one.
	public let roleId: String?

	/// The user's user license type ID.
	public let userLicenseTypeId: String?

	/// Disables access to the organization by the user.
	public let disabled: Bool?

	/// User-defined units for measurement.
	public let units: String?

	/// The user locale information (language and country).
	public var culture: String?

	/// The user preferred number and date format defined in CLDR (only applicable for English and Spanish, i.e. when culture is en or es).
	/// See [Languages](https://developers.arcgis.com/rest/users-groups-and-items/languages.htm#GUID-F2075D30-8644-4A62-915F-D21A4CEB4587) for supported formats. It will inherit from [organization](https://developers.arcgis.com/rest/users-groups-and-items/portal-self.htm) `cultureFormat` if undefined.
	public var cultureFormat: String?

	/// The user preferred region, used to set the featured maps on the home page, content in the gallery, and the default extent of new maps in the Viewer.
	public var region: String?

	/// The file name of the thumbnail used for the user.
	public var thumbnail: String?

	/// The date the user was created.
	@Immutable @MillisecondsSince1970DateCoding
	public var created: Date

	/// The date the user was last modified.
	@Immutable @MillisecondsSince1970DateCoding
	public var modified: Date

	/// An array of groups the user belongs to. See [Group](https://developers.arcgis.com/rest/users-groups-and-items/group.htm) for properties of a group.
	public var groups: [Group]?

	/// The identity provider for the organization.
	public let provider: User.Provider?

	/// Retrieves the content owned by this `User`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKRequestError`.
	/// - Returns: The fetched content.
	public func fetchContent(from gis: GIS) async -> Result<[ContentType], AGKError> {
		let contentURL = await gis.fullURL + ["rest", "content", "users", self.username]

		var p = await Paginator<ContentItem>(client: gis.httpClient, url: contentURL, token: gis.currentToken!)
		var c: [ContentType] = []

		do {
			while try await p.advance().get() {
				if let current = p.current {
					for item in current.items {
						// if let itemType = item.itemType, let type = item.type, let itemItem = item.item {
						// 	if itemType.lowercased() == "url", type.lowercased() == "feature service" {
						// 		if let u = URL(string: itemItem) {
						// 			c.append(.featureServer(featureServer: try FeatureServer(url: u, gis: gis), metadata: item))
						// 		}
						// 	}
						// } else {
						// 	c.append(.other(metadata: item))
						// }

						c.append(.other(metadata: item))
					}
				}
			}
		} catch let error as AGKError {
			return .failure(error)
		} catch {
			fatalError()
		}
		return .success(c)
	}

	/// Updates the information for this `User` on ArcGIS Online or Enterprise.
	/// - Parameter clearEmptyFields: If a property like `self.description` is empty (for example: "" or `nil`),
	/// setting `clearEmptyFields` to `true` will clear that field in ArcGIS Online or ArcGIS Enterprise.
	/// More information at [https://developers.arcgis.com/rest/users-groups-and-items/update-user.htm](https://developers.arcgis.com/rest/users-groups-and-items/update-user.htm).
	///
	/// - Returns: `true` if the user's information was successfully updated, `false` otherwise.
	public func update(clearEmptyFields: Bool = false, gis: GIS) async throws {
		// let updateURL = await gis.fullURL + ["community", "users", self.username]

		// let req = try! GHCHTTPRequest(
		// 	url: updateURL,
		// 	method: .POST,
		// 	body: .string("""
		// 	clearEmptyFields=\(clearEmptyFields)
		// 	\(self.description != nil ? "description=\(self.description!)" : "")
		// 	\(self.tags != nil ? "tags=" + self.tags!.joined(separator: ", ") : "")
		// 	\(self.access != nil ? "access=\(self.access!)" : "")
		// 	\(self.preferredView != nil ? "preferredView=\(self.preferredView!)" : "")
		// 	\(self.thumbnail != nil ? "thumbnail=\(self.thumbnail!)" : "")
		// 	\(self.fullName != nil ? "fullname=\(self.fullName!)" : "")
		// 	\(self.email != nil ? "email=\(self.email!)" : "")
		// 	\(self.culture != nil ? "culture=\(self.culture!)" : "")
		// 	\(self.cultureFormat != nil ? "cultureFormat=\(self.cultureFormat!)" : "")
		// 	\(self.region != nil ? "region=\(self.region!)" : "")
		// 	\(self.idpUsername != nil ? "idpUsername=\(self.idpUsername!)" : "")
		// 	""")
		// )
	}

	public func moveItem(to folder: String) async throws {}

	/// Creates a folder in which items can be placed. Folders are only visible to a user and solely used for organizing content within that user's content space.
	///
	/// - Parameter name: The name of the folder to create.
	/// - Throws: `AGKRequestError`
	/// - Returns: The ID of the created folder
	///
	/// The create user folder operation (POST only) is available only on the user's root folder. Multilevel folders are not supported.
	/// The user provides the title for the folder, which must be unique to that user. The folder ID is generated by the system.
	public func createFolder(name: String, gis: GIS) async -> Result<String?, AGKError> {
		var createFolderURL = await gis.fullURL + ["rest", "content", "users", self.username, "createFolder"]

		createFolderURL.formParams += [
			"title": name,
			"f": "json",
		]

		if let token = await gis.currentToken {
			createFolderURL.formParams.token = token
		}

		let req = try! GHCHTTPRequest(url: createFolderURL, method: .POST)

		let res = await sendAndHandle(request: req, client: gis.httpClient, decodeType: JSON.self)

		switch res {
			case let .success(json): return .success(json["folder"]["id"].string)
			case let .failure(error): return .failure(error)
		}
	}

	public func addFile(name: String, data: Data, folder: String? = nil, type: String = "", tags: [String] = [], gis: GIS) async -> Result<String, AGKError> {
		var addItemURL = await gis.fullURL + ["rest", "content", "users", self.username, "addItem"]

		addItemURL.formParams += [
			"f": "json",
			// 	"token": await gis.currentToken!,
			// 	"title": name,
			// 	"type": "GeoJson"
		]

		var parts: [Subpart] = []

		do {
			try parts.append(
				Subpart(
					contentDisposition: .init(uncheckedName: "file", uncheckedFilename: name),
					contentType: .init(mediaType: .applicationOctetStream),
					body: data
				)
			)
		} catch let error as ContentDisposition.PercentEncodingError {
			return .failure(.requestError(.invalidFilename(name: error.initialValue)))
		} catch {
			fatalError()
		}

		parts.append(Subpart(contentDisposition: ContentDisposition(name: "f"), body: Data("json".utf8)))
		parts.append(Subpart(contentDisposition: ContentDisposition(name: "title"), body: Data(name.utf8)))
		parts.append(Subpart(contentDisposition: ContentDisposition(name: "type"), body: Data(type.utf8)))

		if let f = folder {
			parts.append(Subpart(contentDisposition: ContentDisposition(name: "folder"), body: Data(f.utf8)))
		}

		if let token = await gis.currentToken {
			parts.append(Subpart(contentDisposition: ContentDisposition(name: "token"), body: Data(token.utf8)))
		}

		let multipart = MultipartFormData(body: parts)

		let req = try! GHCHTTPRequest(
			url: addItemURL,
			method: .POST,
			headers: ["Content-Type": "multipart/form-data; boundary=\"\(multipart.boundary)\""],
			body: .bytes(Array(multipart.httpBody))
		)

		switch await gis.httpClient.send(request: req) {
			case let .success(response): return .success(String(response.body!))
			case let .failure(error): return .failure(.requestError(.clientError(error)))
		}
	}

	/// Indicates the level of access of the user: `private`, `org`, `public`, or `account`.
	/// If `private`, the user descriptive information will not be available to others nor will the username be searchable.
	public enum Provider: String, Codable, CaseIterable, Equatable {
		case arcgis,
		     enterprise,
		     google,
		     facebook
		// apple,
		// github
	}

	public enum Role: String, Codable, Equatable {
		/// Organization administrator or custom role with administrative privileges.
		case organizationAdmin = "org_admin"

		/// Organization publisher or custom role with publisher privileges.
		case organizationPublisher = "org_publisher"

		/// Organization user or custom role with user privileges.
		case organizationUser = "org_user"

		// TODO: documentation
		case accountAdmin = "account_admin"

		// TODO: documentation
		case accountUser = "account_user"
	}

	public struct Membership: Codable, Equatable {
		public let username: String?
		public let memberType: String?
		public let applications: Int?
	}
}
