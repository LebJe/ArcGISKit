//
//  ESRIFieldType.swift
//  
//
//  Created by Jeff Lebrun on 1/9/21.
//

import Foundation

/// Field Types.
enum ESRIFieldType: String, CaseIterable, Codable {

	/// Short Integer.
	case esriFieldTypeSmallInteger

	/// Long Integer.
	case esriFieldTypeInteger

	/// Single-precision floating-point number.
	case esriFieldTypeSingle

	/// Double-precision floating-point number.
	case esriFieldTypeDouble

	/// Character string.
	case esriFieldTypeString

	/// Date.
	case esriFieldTypeDate

	/// Long Integer representing an object identifier.
	case esriFieldTypeOID

	/// Geometry.
	case esriFieldTypeGeometry

	/// Binary Large Object.
	case esriFieldTypeBlob

	/// Raster.
	case esriFieldTypeRaster

	/// Globally Unique Identifier.
	case esriFieldTypeGUID

	/// Esri Global ID.
	case esriFieldTypeGlobalID

	/// XML Document.
	case esriFieldTypeXML
}
