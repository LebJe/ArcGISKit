//
//  QueryResponse.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import Foundation
import SwiftyJSON

public struct QueryResponse: Codable, Equatable {
	public let layers: [FeatureLayer]
}

public struct FeatureLayer: Codable, Equatable {
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

public struct Feature: Codable, Equatable {
	public init(geometry: Geometry? = nil, attributes: JSON? = nil) {
		self.geometry = geometry
		self.attributes = attributes
	}

	public var geometry: Geometry?
	public var attributes: JSON?
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
