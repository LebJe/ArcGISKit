//
//  Group.swift
//  
//
//  Created by Jeff Lebrun on 12/23/20.
//

import Foundation
import AsyncHTTPClient

/// The Group resource represents a group (for example, San Bernardino Fires) within the portal.
///
/// The owner is automatically an administrator and is returned in the list of administrators. Administrators can invite, add to, or remove members from a group as well as update or delete the group. The administrator for an organization can also reassign the group to another member of the organization.
///
/// Group members can leave the group. Authenticated users can apply to join a group unless the group is by invitation only.
///
/// The visibility of the group by other users is determined by the `access` property. If the group is private, no one other than the administrators and members of the group will be able to see it. If the group is shared with an organization, all members of the organization will be able to find it.
///
/// To fetch the content owned by a `Group` call `Group.fetchContent()`.
public struct Group: Decodable, Equatable {
	/// The given group ID.
	public let id: String?

	/// The title of the group. This is the name that is displayed to users and by which they refer to the group. Every group must have a title, and it must be unique for a user.
	public let title: String?

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
	public let created: Date

	/// The date the group was last modified.
	public let modified: Date

	/// The access privileges of the group that determine who can see and access the group. This can be set to private, org, or public.
	public let access: String

	/// If the request is made by an authenticated user, a `UserMembership` object is returned containing information about the user's access to the group. This includes the `username` of the calling user; the `memberType`, which specifies the type of membership the user has in the group (owner, member, admin, none); and the `applications` (number of requests to join the group) count available to administrators and owners.
	public let userMembership: UserMembership?

	/// Indicates if the group is protected from deletion. The default value is `false`.
	public let protected: Bool

	/// Only applies to org accounts. Indicates if the group allows joining without requesting membership approval. The default value is `false`.
	public let autoJoin: Bool

	/// If `true`, the group has content category set.
	public let hasCategorySchema: Bool?

	/// If `true`, the group is designated as available for use in Open Data sites.
	public let isOpenData: Bool?

	public var content: [ContentType] = []

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try values.decode(Optional<String>.self, forKey: .id)
		self.title = try values.decode(Optional<String>.self, forKey: .title)
		self.isInvitationOnly = try values.decode(Optional<Bool>.self, forKey: .isInvitationOnly)
		self.owner = try values.decode(Optional<String>.self, forKey: .owner)
		self.description = try values.decode(Optional<String>.self, forKey: .description)
		self.typeKeywords = try values.decode(Optional<[String]>.self, forKey: .typeKeywords)
		self.snippet = try values.decode(Optional<String>.self, forKey: .snippet)
		self.tags = try values.decode(Optional<[String]>.self, forKey: .tags)
		self.phone = try values.decode(Optional<String>.self, forKey: .phone)
		self.sortField = try values.decode(Optional<String>.self, forKey: .sortField)
		self.sortOrder = try values.decode(Optional<SortOrder>.self, forKey: .sortOrder)
		self.isViewOnly = try values.decode(Bool.self, forKey: .isViewOnly)
		self.isFav = try values.decode(Bool.self, forKey: .isFav)
		self.thumbnail = try values.decode(Optional<String>.self, forKey: .thumbnail)
		self.created = try values.decode(Date.self, forKey: .created)
		self.modified = try values.decode(Date.self, forKey: .modified)
		self.access = try values.decode(String.self, forKey: .access)
		self.userMembership = try values.decode(Optional<UserMembership>.self, forKey: .userMembership)
		self.protected = try values.decode(Bool.self, forKey: .protected)
		self.autoJoin = try values.decode(Bool.self, forKey: .autoJoin)
		self.hasCategorySchema = (try? values.decode(Optional<Bool>.self, forKey: .hasCategorySchema)) ?? nil
		self.isOpenData = (try? values.decode(Optional<Bool>.self, forKey: .isOpenData)) ?? nil
	}

	enum CodingKeys: CodingKey {
		case id,
		title,
		isInvitationOnly,
		owner,
		description,
		typeKeywords,
		snippet,
		tags,
		phone,
		sortField,
		sortOrder,
		isViewOnly,
		isFav,
		thumbnail,
		created,
		modified,
		access,
		userMembership,
		protected,
		autoJoin,
		hasCategorySchema,
		isOpenData
	}

	/// Retrieves the content owned by this `Group`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	public mutating func fetchContent(from gis: GIS) {
		do {

			let groupURL = gis.fullURL
				.appendingPathComponent("content")
				.appendingPathComponent("groups")
				.appendingPathComponent(self.id!)
				.absoluteString

			let req = try HTTPClient.Request(
				url: "\(groupURL)?token=\(gis.token!)&start=1&num=100&f=json",
				method: .GET
			)

			let res = try gs.client.execute(request: req).wait()

			if res.status == .ok && res.body != nil {
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .millisecondsSince1970

				let groupContent = try decoder.decode(Pagination<GroupContentItem>.self, from: Data(buffer: res.body!))

				for item in groupContent.items {
					if item.itemType!.lowercased() == "url" && item.type!.lowercased() == "feature service" {
						if let u = URL(string: item.item!) {
							self.content.append(.featureServer(FeatureServer(url: u, gis: gis)))
						}
					}
				}
			}
		} catch {
			print(error)
		}
	}
}

struct GroupContentItem: Codable, Equatable {
	let id: String?
	let item: String?
	let itemType: String?
	let owner: String?
	let uploaded: Date?
	let modified: Date?
	let isOrgItem: Bool?
	let guid: String?
	let name: String?
	let title: String?
	let type: String?
}

/// The order a `Group` is sorted by.
public enum SortOrder: String, Codable, CaseIterable, Equatable {
	case ascending = "asc"
	case descending = "desc"
}
