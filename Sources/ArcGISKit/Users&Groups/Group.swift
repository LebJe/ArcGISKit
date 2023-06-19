// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Date
import GenericHTTPClient
import WebURL

/// The [Group](https://developers.arcgis.com/rest/users-groups-and-items/group.htm) resource represents a group (for example, San Bernardino Fires) within the portal.
///
/// The owner is automatically an administrator and is returned in the list of administrators. Administrators can invite, add to, or remove members from a group as well as update or delete the group. The administrator for an organization can also reassign the group to another member of the organization.
///
/// Group members can leave the group. Authenticated users can apply to join a group unless the group is by invitation only.
///
/// The visibility of the group by other users is determined by the `access` property. If the group is private, no one other than the administrators and members of the group will be able to see it. If the group is shared with an organization, all members of the organization will be able to find it.
///
/// To fetch the content owned by a `Group` call `Group.fetchContent()`.
public struct Group: Equatable, Codable {
	/// The given group ID.
	public let id: String?

	/// The title of the group. This is the name that is displayed to users and by which they refer to the group. Every group must have a title, and it must be unique for a user.
	public let title: String

	/// If this is set to true, users will not be able to apply to join the group.
	public let isInvitationOnly: Bool?

	/// The owner user name of the group.
	public let owner: String?

	/// The group description.
	public let description: String?

	/// An array of keywords that further describes a group.
	public let typeKeywords: [String]?

	/// The group summary.
	public let snippet: String?

	/// User-defined tags that describe the group.
	public let tags: [String]?

	/// The contact information for the group.
	public let phone: String?

	/// The sorted field.
	public let sortField: String?

	/// The sort order, either descending or ascending.
	public let sortOrder: SortOrder?

	/// Boolean value indicating whether the results are only for viewing.
	public let isViewOnly: Bool

	/// Boolean value indicating whether marked in favorites.
	public let isFav: Bool

	/// The URL to the thumbnail used for the group. All group thumbnails are relative to the URL: `https://[<community-url>](https://developers.arcgis.com/rest/users-groups-and-items/community-root.htm)/groups/<groupId>/info`.
	public let thumbnail: String?

	/// THe date the group was created.
	@Immutable @MillisecondsSince1970DateCoding
	public var created: Date

	/// The date the group was last modified.
	@Immutable @MillisecondsSince1970DateCoding
	public var modified: Date

	/// The access privileges of the group that determine who can see and access the group. This can be set to private, org, or public.
	public let access: Access

	/// If the request is made by an authenticated user, a `UserMembership` object is returned containing information about the user's access to the group. This includes the `username` of the calling user; the `memberType`, which specifies the type of membership the user has in the group (owner, member, admin, none); and the `applications` (number of requests to join the group) count available to administrators and owners.
	public let userMembership: User.Membership?

	/// Indicates if the group is protected from deletion. The default value is `false`.
	public let protected: Bool

	/// Only applies to org accounts. Indicates if the group allows joining without requesting membership approval. The default value is `false`.
	public let autoJoin: Bool

	/// If `true`, the group has content category set.
	public let hasCategorySchema: Bool?

	/// If `true`, the group is designated as available for use in Open Data sites.
	public let isOpenData: Bool?

	/// Retrieves the content owned by this `Group`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKRequestError`.
	/// - Returns: The fetched content.
	public func fetchContent(from gis: GIS) async -> Result<[ContentType], AGKError> {
		let groupURL = await gis.fullURL + ["content", "groups", self.id!]

		var p = await Paginator<ContentItem>(client: gis.httpClient, url: groupURL, token: gis.currentToken!)
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
}

/// The order results are sorted by.
public enum SortOrder: String, Codable, CaseIterable, Equatable {
	/// Sort in ascending order.
	case ascending = "asc"

	/// Sort in descending order.
	case descending = "desc"
}
