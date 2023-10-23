// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import ExtrasJSON
import Foundation
import GenericHTTPClient
import WebURL

/// A Geometry Service contains utility methods that provide access to sophisticated and frequently used geometric
/// operations.
///
/// * Use a geometry service to do the following:
///   * Buffer, project, and simplify geometry.
///   * Calculate areas and lengths for geometry.
///   * Determine spatial relations and label points.
///   * Determine distances between geometries.
///   * Apply Union, Intersection, and Difference operations between geometries.
///   * Autocomplete, generalize, reshape, offset, trim or extend, and compute convex hulls of geometries.
///   * Convert to or from geographic coordinate strings.
///
/// Reference: https://developers.arcgis.com/rest/services-reference/enterprise/geometry-service.htm
public struct GeometryServer {
	public static func == (lhs: GeometryServer, rhs: GeometryServer) -> Bool {
		lhs.url == rhs.url
	}

	public let url: WebURL
	var gis: GIS

	/// GeometryServer
	/// - Parameters:
	///   - url: The URL to the Geometry Server, e.g:
	/// "https://machine.domain.com/webadaptor/rest/services/ServiceName/GeometryServer"
	///   - gis: The `GIS` to use to authenticate.
	public init(
		url: URL = URL(string: "https://utility.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer")!,
		gis: GIS
	) {
		self.url = WebURL(url.absoluteString)!
		self.gis = gis
	}

	/// This operation projects an array of input geometries from the input spatial reference to the output spatial
	/// reference.
	///
	/// At 10.1 and later, this operation calls `simplify` on the input geometries.
	/// - Parameters:
	///   - geometries: The array of geometries to be projected. All geometries in this array should be of the type defined
	/// by ``GeometryServer/Geometry/geometryType``.
	///   - inputSpatialReference:
	///   - outputSpatialReference:
	///   - transformForward: A Boolean value indicating whether or not to transform forward. The forward or reverse
	/// direction of the transformation is implied in the name of the transformation.
	///   - vertical: Specifies whether to project vertical coordinates. If `vertical` is set to `true`, both `inSR` and
	/// `outSR` must have a vertical coordinate system.
	///
	/// - Reference: <https://developers.arcgis.com/rest/services-reference/enterprise/project.htm>
	public func project(
		geometry: Self.Geometry,
		inputSpatialReference: SpatialReference,
		outputSpatialReference: SpatialReference,
		transformForward: Bool = false,
		vertical: Bool = false,
		withToken: Bool = false
	) async -> Result<GeometryResponse, AGKError> {
		var newURL = self.url
		newURL.pathComponents += ["project"]

		let geosJSON = try! String(bytes: XJSONEncoder().encode(geometry), encoding: .utf8)!
		let inSRJSON = try! String(bytes: XJSONEncoder().encode(inputSpatialReference), encoding: .utf8)!
		let outSRJSON = try! String(bytes: XJSONEncoder().encode(outputSpatialReference), encoding: .utf8)!

		let req = try! await GHCHTTPRequest(
			url: newURL,
			method: .POST,
			headers: ["Content-Type": "application/x-www-form-urlencoded"],
			body: .string(
				"""
				f=json\(
					self.gis
						.currentToken != nil && withToken ? "&token=\(self.gis.currentToken!)" : ""
				)&geometries=\(geosJSON.urlQueryEncoded)&inSR=\(inSRJSON.urlQueryEncoded)&outSR=\(
					outSRJSON
						.urlQueryEncoded
				)&transformForward=\(transformForward)&vertical=\(vertical)
				"""
			)
		)

		switch await sendAndHandle(request: req, client: self.gis.httpClient, decodeType: GeometryResponse.self) {
			case let .success(geoRes): return .success(geoRes)
			case let .failure(error): return .failure(error)
		}
	}

	public struct GeometryResponse: Decodable {
		@FallbackDecoding<EmptyArray>
		public var geometries: [ArcGISKit.AGKGeometry]
	}

	public struct Geometry: Encodable {
		public var geometryType: GeoType

		public var geometries: [ArcGISKit.AGKGeometry]

		public init(geometryType: GeometryServer.Geometry.GeoType, geometries: [AGKGeometry]) {
			self.geometryType = geometryType
			self.geometries = geometries
		}

		public enum GeoType: String, Codable, Equatable {
			case point = "esriGeometryPoint"
			case multiPoint = "esriGeometryMultipoint"
			case polyline = "esriGeometryPolyline"
			case polygon = "esriGeometryPolygon"
		}
	}
}
