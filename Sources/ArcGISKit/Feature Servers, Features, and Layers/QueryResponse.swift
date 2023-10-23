// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Data
import struct Foundation.Date
import JSON
import WebURL

public struct QueryResponse: Codable, Equatable {
	public var layers: [FeatureLayer]
}

public struct GeometryProperties: Codable, Equatable {
	public let shapeAreaFieldName: String?
	public let shapeLengthFieldName: String?
	public let units: String?
}

public struct CodedValue: Codable, Equatable {
	public let name: String?
	public let code: Either<String, Int>?
}

public struct TableDomain: Codable, Equatable {
	public let type: TableDomain.DomainType
	public let name: String?
	public let range: [Int]?
	public let codedValues: [CodedValue]?
	public let description: String?
	public let mergePolicy: String?
	public let splitPolicy: String?

	public enum DomainType: String, Codable, Equatable {
		case range
		case codedValue
		case inherited
	}
}

public struct TableField: Codable, Equatable {
	public let name: String
	public let type: ESRIFieldType
	public let alias: String?
	public let domain: TableDomain?
	public let editable: Bool?
	public let nullable: Bool
	public let exactMatch: Bool?
	public let length: Int?
	public let sqlType: String
	public let defaultValue: JSON?
}

struct AttachmentResponse: Codable {
	@Immutable @Base64Coding
	var attachment: Data

	enum CodingKeys: String, CodingKey {
		case attachment = "Attachment"
	}
}

struct AttachmentInfosResponse: Codable {
	var attachmentInfos: [AGKAttachment]
}

public struct AGKAttachment: Codable, Equatable {
	init(
		keywords: String?,
		size: Int,
		contentType: String?,
		globalId: String?,
		parentGlobalId: String?,
		exifInfo: [ExifInfo]?,
		name: String?,
		id: Int,
		data: Data? = nil
	) {
		self.keywords = keywords
		self.size = size
		self.contentType = contentType
		self.globalId = globalId
		self.parentGlobalId = parentGlobalId
		self.exifInfo = exifInfo
		self.name = name
		self.id = id
		self.data = data
	}

	public let keywords: String?
	public let size: Int
	public let contentType: String?
	public let globalId: String?
	public let parentGlobalId: String?
	public let exifInfo: [ExifInfo]?
	public let name: String?
	public let id: Int

	@OmitCoding
	public var data: Data? = nil
}

public struct AGKGeometry: Codable, Equatable {
	public init(
		x: Double? = nil,
		y: Double? = nil,
		rings: [[[Double]]]? = nil,
		spatialReference: SpatialReference? = nil
	) {
		self.x = x
		self.y = y
		self.rings = rings
		self.spatialReference = spatialReference
	}

	public var x: Double?
	public var y: Double?
	public var rings: [[[Double]]]?
	public var spatialReference: SpatialReference? = nil

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Self.CodingKeys.self)

		try container.encodeIfPresent(self.x, forKey: .x)
		try container.encodeIfPresent(self.y, forKey: .y)
		try container.encodeIfPresent(self.rings, forKey: .rings)
		try container.encodeIfPresent(self.spatialReference, forKey: .spatialReference)
	}
}
