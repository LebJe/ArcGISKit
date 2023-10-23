// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers

/// A feature service can contain datasets (for example, tables and views) with or without a spatial column. Datasets
/// with a spatial column are considered layers; those without a spatial column are considered tables. A feature service
/// allows clients to query and edit feature geometry and attributes.
///
/// This resource provides basic information about the feature service, including the feature layers and tables that it
/// contains, the service description, and so on.
public struct FeatureService: Codable, Equatable {
	public let currentVersion: Double?
	public let serviceDescription: String
	public let hasVersionedData: Bool?
	public let supportsDisconnectedEditing: Bool?
	public let supportsDatumTransformation: Bool?
	public let supportsReturnDeleteResults: Bool?
	public let hasStaticData: Bool?
	public let maxRecordCount: Int?
	public let hasAttachments: Bool?
	public let supportedQueryFormats: String?
	public let supportsRelationshipsResource: Bool?

	@Immutable @CodingUses<CommaSeparatedCapabilityCoder>
	public var capabilities: [Capability]

	public let description: String?
	public let copyrightText: String?
	public let userTypeExtensions: [String]?
	public let advancedEditingCapabilities: AdvancedEditingCapabilities?
	public let spatialReference: SpatialReference?
	public let initialExtent: Extent?
	public let fullExtent: Extent?
	public let validationSystemLayers: ValidationSystemLayer?
	public let extractChangesCapabilities: ExtractChangesCapability?
	public let syncCapabilities: SyncCapability?
	public let editorTrackingInfo: EditorTrackingInfo?
	public let allowGeometryUpdates: Bool?
	public let units: String?
	public let syncEnabled: Bool?
	public let datumTransformations: [DatumTransformation]?
	public let layers: [Layer]?
	public let tables: [Table]?
	public let relationships: [Relationship]?
	public let controllerDatasetLayers: ControllerDatasetLayer?
	public let heightModelInfo: HeightModelInfo?
	public let enableZDefaults: Bool?
	public let supportsDynamicLayers: Bool?
	public let allowUpdateWithoutMValues: Bool?
	public let supportsVCSProjection: Bool?
	public let referenceScale: Int?
	public let serviceItemId: String?
}

public enum Capability: String, CaseIterable, Codable {
	case
		create,
		delete,
		query,
		update,
		editing,
		sync,
		uploads,
		extract,
		changeTracking = "changetracking"
}

public struct AdvancedEditingCapabilities: Codable, Equatable {
	public let supportsSplit: Bool?
	public let supportsReturnServiceEditsInSourceSR: Bool?
}

public struct SpatialReference: Codable, Equatable {
	public let wkid: Int?
	public let latestWkid: Int?
	public let vcsWkid: Int?
	public let wkt: String?
	public let latestWkt: String?
	public let latestVcsWkid: Int?
	public let xyTolerance: Double?
	public let zTolerance: Double?
	public let mTolerance: Double?
	public let falseX: Double?
	public let falseY: Double?
	public let xyUnits: Double?
	public let falseZ: Double?
	public let zUnits: Double?
	public let falseM: Double?
	public let mUnits: Double?

	public init(
		wkid: Int? = nil,
		latestWkid: Int? = nil,
		vcsWkid: Int? = nil,
		wkt: String? = nil,
		latestWkt: String? = nil,
		latestVcsWkid: Int? = nil,
		xyTolerance: Double? = nil,
		zTolerance: Double? = nil,
		mTolerance: Double? = nil,
		falseX: Double? = nil,
		falseY: Double? = nil,
		xyUnits: Double? = nil,
		falseZ: Double? = nil,
		zUnits: Double? = nil,
		falseM: Double? = nil,
		mUnits: Double? = nil
	) {
		self.wkid = wkid
		self.latestWkid = latestWkid
		self.vcsWkid = vcsWkid
		self.wkt = wkt
		self.latestWkt = latestWkt
		self.latestVcsWkid = latestVcsWkid
		self.xyTolerance = xyTolerance
		self.zTolerance = zTolerance
		self.mTolerance = mTolerance
		self.falseX = falseX
		self.falseY = falseY
		self.xyUnits = xyUnits
		self.falseZ = falseZ
		self.zUnits = zUnits
		self.falseM = falseM
		self.mUnits = mUnits
	}
}

public struct Layer: Codable, Equatable {
	public let id: Int
	public let name: String?
	public let parentLayerId: Int?
	public let defaultVisibility: Bool?
	public let subLayerIds: [String]?
	public let minScale: Int?
	public let maxScale: Int?
	public let geometryType: String?
	public let type: String?
}

public struct Table: Codable, Equatable {
	public let id: Int
	public let name: String?
}

public struct Relationship: Codable, Equatable {
	public let id: Int
	public let name: String?
}

public struct ControllerDatasetLayer: Codable, Equatable {
	public let topologyLayerIds: [Int]?
}

public struct HeightModelInfo: Codable, Equatable {
	public let heightModel: String?
	public let vertCRS: String?
	public let heightUnit: String?
}

public enum DatumTransformation: Codable, Equatable {
	case wkid(Int)
	case wkt(WKT)
	case geoTransforms([GeoTransform])

	public struct WKT: Codable, Equatable {
		public let wkt: String
	}

	private struct G: Codable {
		let geoTransforms: [GeoTransform]
	}

	public init(from decoder: Decoder) throws {
		let json = try JSON(from: decoder)

		if let wkid = json.int {
			self = .wkid(wkid)
		} else if let wkt = try? WKT(json: json) {
			self = .wkt(wkt)
		} else if let geoTransforms = try? G(json: json) {
			self = .geoTransforms(geoTransforms.geoTransforms)
		} else {
			throw DecodingError.dataCorrupted(.init(
				codingPath: [],
				debugDescription: "Expected a Integer (wkid) or an object (WKT or array of GeoTransform).\nRaw JSON: \(json.description)"
			))
		}
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
			case let .wkid(wkid):
				var c = encoder.singleValueContainer()
				try c.encode(wkid)
			case let .wkt(wkt):
				try wkt.encode(to: encoder)
			case let .geoTransforms(geoTransforms):
				try G(geoTransforms: geoTransforms).encode(to: encoder)
		}
	}
}

public struct GeoTransform: Codable, Equatable {
	public let wkid: Int?
	public let wkt: String?
	public let latestWkid: Int?
	public let transformForward: Bool?
	public let name: String?
}

public struct Extent: Codable, Equatable {
	public let xmin: Double
	public let ymin: Double
	public let zmin: Double?
	public let xmax: Double
	public let ymax: Double
	public let zmax: Double?
	public let spatialReference: SpatialReference?
}

public struct ValidationSystemLayer: Codable, Equatable {
	public let validationPointErrorlayerId: Int?
	public let validationLineErrorlayerId: Int?
	public let validationPolygonErrorlayerId: Int?
	public let validationObjectErrortableId: Int?
}

public struct ExtractChangesCapability: Codable, Equatable {
	public let supportsReturnIdsOnly: Bool?
	public let supportsReturnExtentOnly: Bool?
	public let supportsReturnAttachments: Bool?
	public let supportsLayerQueries: Bool?
	public let supportsSpatialFilter: Bool?
	public let supportsReturnFeature: Bool?
}

public struct SyncCapability: Codable, Equatable {
	public let supportsASync: Bool?
	public let supportsRegisteringExistingData: Bool?
	public let supportsSyncDirectionControl: Bool?
	public let supportsPerLayerSync: Bool?
	public let supportsPerReplicaSync: Bool?
	public let supportsRollbackOnFailure: Bool?
	public let supportedSyncDataOptions: Int?
	public let supportsQueryWithDatumTransformation: Bool?
}

public struct EditorTrackingInfo: Codable, Equatable {
	public let enableEditorTracking: Bool?
	public let enableOwnershipAccessControl: Bool?
	public let allowOthersToUpdate: Bool?
	public let allowOthersToDelete: Bool?
}
