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
	public let capabilities: String?
}

// public let <#name#>: <#Data type#>
