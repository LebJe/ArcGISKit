//
//  FeatureService.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import Foundation

/// A feature service can contain datasets (for example, tables and views) with or without a spatial column. Datasets with a spatial column are considered layers; those without a spatial column are considered tables. A feature service allows clients to query and edit feature geometry and attributes.
///
/// This resource provides basic information about the feature service, including the feature layers and tables that it contains, the service description, and so on.
public struct FeatureService: Codable, Equatable {
	public let currentVersion: Double?
	public let serviceDescription: String?
	public let hasVersionedData: Bool?
	public let supportsDisconnectedEditing: Bool?
	public let supportsDatumTransformation: Bool?
	public let supportsReturnDeleteResults: Bool?
	public let hasStaticData: Bool?
	public let maxRecordCount: Int?
	public let supportedQueryFormats: String?
	public let supportsRelationshipsResource: Bool?
	let capabilities: String
	public var Capabilities: [Capability] {
		capabilities.components(separatedBy: ",").map({ Capability(rawValue: $0.lowercased())! })
	}

	public let description: String?
	public let copyrightText: String?
	public let userTypeExtensions: [String]?
	public let advancedEditingCapabilities: AdvancedEditingCapabilities?
	public let spatialReference: SpatialReference?
	// ...
	public let allowGeometryUpdates: Bool?
	public let units: String?
	public let syncEnabled: Bool
	let layers: [Layer]?
}

public enum Capability: String, CaseIterable, Codable {
	case create, delete, query, update, editing, sync, uploads
}

public struct AdvancedEditingCapabilities: Codable, Equatable {
	public let supportsSplit: Bool?
	public let supportsReturnServiceEditsInSourceSR: Bool?
}

public struct SpatialReference: Codable, Equatable {
	public let wkid: Int?
	public let latestWkid: Int?
}

struct Layer: Codable, Equatable {
	public let id: Int
	public let name: String?
}
