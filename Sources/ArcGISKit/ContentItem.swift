// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Date

/// An item (a unit of content) in the portal. Each item has a unique identifier and a well known URL that is
/// independent of the user owning the item.
///
/// An item can have associated JSON data that's available via the item data resource. For example, an item of type Map
/// Package returns the actual bits corresponding to the map package via the item data resource.
///
/// The `numViews` is incremented when an item is opened.
///
/// - Reference: https://developers.arcgis.com/rest/users-groups-and-items/item.htm
public struct ContentItem: Codable, Equatable {
	/// The unique ID for this item.
	public let id: String

	/// The title of the item. This is the name that's displayed to users and by which they refer to the item. Every item
	/// must have a title.
	public let title: String

	/// The file name of the item for file types. Read-only.
	public let name: String?

	/// The GIS content type of this item.
	///
	/// Example types include Web Map, Map Service, Shapefile, and Web Mapping Application.
	///
	/// See the overview section of [Items and item
	/// types](https://developers.arcgis.com/rest/users-groups-and-items/items-and-item-types.htm) to get an understanding
	/// of the item type hierarchy.
	public let type: String

	/// An array of keywords that further describes the type of this item. Each item is tagged with a set of type keywords
	/// that are derived based on its primary type.
	public let typeKeywords: [String]?

	/// The username of the user who owns this item.
	public let owner: String?

	/// The URL for the resource represented by the item. Applies only to items that represent web-accessible resources
	/// such as map services.
	public let url: String?

	/// The size of the item in bytes.
	public let size: Int?

	/// Protects the item from deletion. `false` is the default.
	public let protected: Bool?

	/// Indicates if comments are allowed on the item.
	public let commentsEnabled: Bool?

	public let isOrgItem: Bool?

	public let guid: String?

	/// The date the item was created. Shown in UNIX time in milliseconds.
	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var created: Date?

	// ///
	// @Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	// public var uploaded: Date?

	/// The date the item was last modified. Shown in UNIX time in milliseconds.
	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var modified: Date?

	/// A short summary description of the item.
	public let snippet: String?

	/// Item description.
	public let description: String?

	public let documentation: String?

	/// An array of organization categories that are set on the item.
	public let categories: [String]?

	/// An array that primarily applies to a list of categories that the application item is applicable to.
	public let appCategories: [String]?

	/// Primarily applies to thumbnails associated with an application. The URL to the thumbnail used for the application.
	public let thumbnail: String?

	/// Primarily applies to the banner associated with an application. The URL to the banner used for the application.
	public let banner: String?

	/// An array that primarily applies to screenshots associated with an application. The URL to the screenshots used for
	/// the application.
	public let screenshots: [String]?

	/// The item locale information (language and country).
	public let culture: String?

	/// An array that primarily applies to languages associated with the application.
	public let languages: [String]?

	/// An array of user defined tags that describe the item.
	public let tags: [String]?

	/// Indicates the level of access to the item.
	public let access: Access?

	/// Information on the source of the item and its copyright status.
	public let accessInformation: String?

	/// Any license information or restrictions.
	public let licenseInfo: String?

	/// An array that primarily applies to industries associated with the application.
	public let industries: [String]?

	/// If `true`, the item is listed in the marketplace
	public let listed: Bool?

	/// The ID of the folder in which the owner has stored the item. The property is only returned to the item owner or the
	/// org admin.
	public var ownerFolder: String?

	/// Number of comments on the item.
	public let numComments: Int?

	/// Number of ratings on the item.
	public let numRating: Int?

	/// Average rating. Uses a weighted average called "Bayesian average."
	public let avgRating: Double?

	/// Number of views of the item.
	public let numViews: Int?

	/// (Optional) Indicates user's control to the item.
	///
	/// Values: `admin` (for item owner and org admin) | `update` (for members of groups with item update capability that
	/// the item is shared with)
	public let itemControl: ItemControl?

	/// Item information completeness score based upon item snippet, thumbnail, description, title, tags etc.
	public let scoreCompleteness: Double?

	/// The coordinate system of the item.
	public let spatialReference: Either<String, SpatialReference>?

	/// An array that defines the bounding rectangle of the item. Should always be in WGS84.
	public let extent: [[Double]]?

	// public let item: String?
	// public let itemType: String?
}

public enum Access: String, Codable, Equatable {
	case account
	case `private`
	case shared
	case organization = "org"
	case `public`
}

public enum ItemControl: String, Codable {
	case user
	case update
}
