//
//  ContentItem.swift
//
//
//  Created by Jeff Lebrun on 1/1/21.
//

import CodableWrappers
import Foundation

public struct ContentItem: Codable, Equatable {
	public let id: String?
	public let item: String?
	public let itemType: String?
	public let owner: String?

	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var uploaded: Date?

	@Immutable @OptionalCoding<MillisecondsSince1970DateCoding>
	public var modified: Date?

	public let isOrgItem: Bool?
	public let guid: String?
	public let name: String?
	public let title: String?
	public let type: String?
}
