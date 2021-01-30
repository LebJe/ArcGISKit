//
//  QueryResponse.swift
//
//
//  Created by Jeff Lebrun on 1/9/21.
//

import CodableWrappers
import Foundation
import SwiftyJSON

public struct QueryResponse: Codable, Equatable {
	public var layers: [FeatureLayer]
}

public struct FeatureLayer: Codable, Equatable {
	@OmitCoding
	var featureServerURL: URL? = nil

	public let id: Int
	public let objectIdFieldName: String?
	public let globalIdFieldName: String?
	public let geometryType: String?
	public let spatialReference: SpatialReference?
	public let geometryProperties: GeometryProperties?
	public let fields: [Field]
	public var features: [Feature]
}

public struct GeometryProperties: Codable, Equatable {
	public let shapeAreaFieldName: String?
	public let shapeLengthFieldName: String?
	public let units: String?
}

public struct CodedValues: Codable, Equatable {
	public let name: String?
	public let code: JSON?
}

public struct Domain: Codable, Equatable {
	public let type: String
	public let name: String?
	public let mergePolicy: String?
	public let splitPolicy: String?
	public let codedValues: [CodedValues]
}

public struct Field: Codable, Equatable {
	public let name: String
	public let type: ESRIFieldType
	public let alias: String?
	public let sqlType: String
	public let domain: Domain?
	public let length: Int?
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
	var attachmentInfos: [Attachment]
}

public struct Attachment: Codable, Equatable {
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

public struct Geometry: Codable, Equatable {
	public init(x: Double? = nil, y: Double? = nil, rings: [[[Double]]]? = nil) {
		self.x = x
		self.y = y
		self.rings = rings
	}

	public var x: Double?
	public var y: Double?
	public var rings: [[[Double]]]?
}
