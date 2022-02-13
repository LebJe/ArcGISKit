// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

/// Field Types.
public enum ESRIFieldType: String, CaseIterable, Codable, Equatable {
	/// Short Integer.
	case shortInteger = "esriFieldTypeSmallInteger"

	/// Long Integer.
	case longInteger = "esriFieldTypeInteger"

	/// Single-precision floating-point number.
	case singlePrecisionFloatingPoint = "esriFieldTypeSingle"

	/// Double-precision floating-point number.
	case doublePrecisionFloatingPoint = "esriFieldTypeDouble"

	/// Character string.
	case string = "esriFieldTypeString"

	/// Date.
	case date = "esriFieldTypeDate"

	/// Long Integer representing an object identifier.
	case ojectID = "esriFieldTypeOID"

	/// Geometry.
	case geometry = "esriFieldTypeGeometry"

	/// Binary Large Object.
	case blob = "esriFieldTypeBlob"

	/// Raster.
	case raster = "esriFieldTypeRaster"

	/// Globally Unique Identifier.
	case globalUniqueID = "esriFieldTypeGUID"

	/// Esri Global ID.
	case globalID = "esriFieldTypeGlobalID"

	/// XML Document.
	case xmlDoc = "esriFieldTypeXML"
}
