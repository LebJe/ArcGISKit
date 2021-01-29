//
//  User.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import CodableWrappers
import NIO

/// A `User` resource represents a registered user of the portal.
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
	public let fullName: String?

	/// The username of the given user.
	public let username: String

	/// The original username if using enterprise logins.
	public let idpUsername: String?

	/// The user's e-mail address.
	public let email: String?

	/// A description of the user.
	public let description: String?

	/// User-defined tags that describe the user.
	public let tags: [String]?

	/// The number of credits available to the user.
	public let availableCredits: Double?

	/// The number of credits allocated to the user.
	public let assignedCredits: Double?

	/// The user's preferred view for content, either web or GIS.
	public let preferredView: String?

	/// Indicates the level of access of the user: private, org, or public. If private, the user descriptive information will not be available to others nor will the username be searchable.
	public let access: String?

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

	/// Values: `org_admin` (organization administrator or custom role with administrative privileges) | `org_publisher` (organization publisher or custom role with publisher privileges) | `org_user` (organization user or custom role with user privileges)
	public let role: String?

	/// An array of `Privilege`s for this `User`. For a complete listing, see [Privileges](https://developers.arcgis.com/rest/users-groups-and-items/privileges.htm#ESRI_SECTION2_3EAEA3BADD1446A68EA07F9F46F6690C).
	public let privileges: [Privilege]?

	/// (Optional) The ID of the user's role if it is a custom one.
	public let roleId: String?

	/// The user's user license type ID.
	public let userLicenseTypeId: String?

	/// Disables access to the organization by the user.
	public let disabled: Bool?

	/// User-defined units for measurement.
	public let units: String?

	/// The user locale information (language and country).
	public let culture: String?

	/// The user preferred number and date format defined in CLDR (only applicable for English and Spanish, i.e. when culture is en or es).
	/// See [Languages](https://developers.arcgis.com/rest/users-groups-and-items/languages.htm#GUID-F2075D30-8644-4A62-915F-D21A4CEB4587) for supported formats. It will inherit from [organization](https://developers.arcgis.com/rest/users-groups-and-items/portal-self.htm) `cultureFormat` if undefined.
	public let cultureFormat: String?

	/// The user preferred region, used to set the featured maps on the home page, content in the gallery, and the default extent of new maps in the Viewer.
	public let region: String?

	/// The file name of the thumbnail used for the user.
	public let thumbnail: String?

	/// The date the user was created.
	@Immutable @MillisecondsSince1970DateCoding
	public var created: Date

	/// The date the user was last modified.
	@Immutable @MillisecondsSince1970DateCoding
	public var modified: Date

	/// An array of groups the user belongs to. See [Group](https://developers.arcgis.com/rest/users-groups-and-items/group.htm) for properties of a group.
	public var groups: [Group]?

	/// The identity provider for the organization.
	public let provider: Provider?

	/// Retrieves the content owned by this `User`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKRequestError`.
	/// - Returns: The fetched content.
	public func fetchContent(from gis: GIS) throws -> EventLoopFuture<[ContentType]> {
		let contentURL = gis.fullURL
			.appendingPathComponent("rest")
			.appendingPathComponent("content")
			.appendingPathComponent("users")
			.appendingPathComponent(self.username)

		return try getContent(client: gis.client, token: gis.token!, url: contentURL, decodeType: ContentItem.self)
			.flatMapThrowing({ items in
				var c: [ContentType] = []
				for item in items {
					if let itemType = item.itemType, let type = item.type, let itemItem = item.item {
						if itemType.lowercased() == "url" && type.lowercased() == "feature service" {
							if let u = URL(string: itemItem) {
								c.append(.featureServer(featureServer: try FeatureServer(url: u, gis: gis), metadata: item))
							}
						}
					} else {
						c.append(.other(metadata: item))
					}
				}

				return c
			})
	}
}

public enum Provider: String, Codable, CaseIterable, Equatable {
	case arcgis, enterprise, google, facebook, apple, github
}

public struct UserMembership: Codable, Equatable {
	public let username: String?
	public let memberType: String?
	public let applications: Int?
}
