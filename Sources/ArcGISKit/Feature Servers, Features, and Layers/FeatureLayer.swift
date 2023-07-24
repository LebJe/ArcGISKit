// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import JSON
import WebURL

public struct FeatureLayer: Codable, Equatable {
	@OmitCoding
	var featureServerURL: WebURL? = nil

	public let id: Int
	public var objectIdFieldName: String? = nil

	@FallbackDecoding<EmptyArray>
	public var objectIds: [Int]

	public var count: Int? = nil
	public var globalIdFieldName: String? = nil
	public var geometryType: String? = nil
	public var spatialReference: SpatialReference? = nil
	public var geometryProperties: GeometryProperties? = nil

	@FallbackCoding<EmptyArray>
	public var fields: [TableField]? = []

	@FallbackDecoding<EmptyArray>
	public var features: [AGKFeature]
}

public struct FeatureLayerInfo: Codable, Equatable {
	public let drawingInfo: DrawingInfo?

	@FallbackDecoding<EmptyArray>
	public var fields: [TableField]

	public let geometryField: TableField?
}

public struct DrawingInfo: Codable, Equatable {
	public let renderer: Renderer
	public let scaleSymbols: Bool
	public let transparency: Int
	// let labelingInfo: Any?

	public struct Renderer: Codable, Equatable {
		public let type: String
		public let field1: String?

		@FallbackDecoding<EmptyArray>
		public var uniqueValueInfos: [UniqueValueInfo]

		public let fieldDelimiter: String?
		public let authoringInfo: AuthoringInfo?

		public struct UniqueValueInfo: Codable, Equatable {
			public struct Symbol: Codable, Equatable {
				public struct Outline: Codable, Equatable {
					public let type: String
					public let style: String?
					public let color: [Int]
					public let width: Double
				}

				public let type: String?
				public let style: String?
				public let color: [Int]?
				public let outline: Outline?
			}

			public let symbol: Symbol
			public let value: String
			public let label: String
		}

		public struct AuthoringInfo: Codable, Equatable {
			public struct ColorRamp: Codable, Equatable {
				public struct ColorRamp: Codable, Equatable {
					public let type: String
					public let algorithm: String
					public let fromColor: [Int]
					public let toColor: [Int]
				}

				public let type: String
				public let colorRamps: [ColorRamp]
			}

			public let colorRamp: ColorRamp?
		}
	}
}
