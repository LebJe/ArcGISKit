// Copyright (c) 2022 Jeff Lebrun
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
	public var globalIdFieldName: String? = nil
	public var geometryType: String? = nil
	public var spatialReference: SpatialReference? = nil
	public var geometryProperties: GeometryProperties? = nil
	public var fields: [Field] = []
	public var features: [Feature] = []
}
