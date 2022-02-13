// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Data
import struct Foundation.Date

struct RequestTokenResponse: Codable {
	let token: String

	@Immutable @MillisecondsSince1970DateCoding
	var expires: Date
	let ssl: Bool
}

struct RequestOAuthTokenResponse: Codable {
	let accessToken: String

	@Immutable @MillisecondsSince1970DateCoding
	var expiresIn: Date

	let username: String?
	let ssl: Bool?
	let refreshToken: String?

	enum CodingKeys: String, CodingKey {
		case expiresIn = "expires_in"
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
		case username
		case ssl
	}
}

struct QueryAttachmentResponse: Codable {
	@Immutable @Base64Coding
	var Attachment: Data
}

struct QueryAttachmentsResponse: Codable, Equatable {
	let attachmentGroups: [AttachmentGroup]
}

public struct AttachmentGroup: Codable, Equatable {
	public let parentObjectId: Int
	public let parentGlobalId: String?
	public let attachmentInfos: [Attachment]
}

public struct ExifInfo: Codable, Equatable {
	public let name: String
	public let tags: [ExifInfoTags]
}

public struct ExifInfoTags: Codable, Equatable {
	public let name: String
	public let description: String?
	public let value: JSON?
}
