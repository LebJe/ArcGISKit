// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import AsyncHTTPClient
import CodableWrappers
import struct Foundation.Data
import struct Foundation.UUID
import JSON
@_exported import MultipartFormData
import WebURL

public struct Feature: Codable, Equatable {
	public init(geometry: Geometry? = nil, attributes: JSON = JSON()) {
		self.geometry = geometry
		self.attributes = attributes
	}

	@OmitCoding
	var featureServerURL: WebURL? = nil

	@OmitCoding
	var featureLayerID: Int? = 0

	var fullURL: WebURL {
		(self.featureServerURL! + String(self.featureLayerID!)) + String(self.attributes.OBJECTID.int ?? 0)
	}

	public var geometry: Geometry?
	public var attributes: JSON

	/// The `Attachment`s contained in this `Feature`.
	@OmitCoding
	public var attachments: [Attachment]? = nil

	/// Fetch all the `Attachment`s contained in this `Feature`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Returns: the array of `Attachment`s.
	public func fetchAttachments(gis: GIS) async throws -> [Attachment] {
		var attachmentsURL = self.fullURL + "attachments"
		attachmentsURL.formParams.f = "json"

		if let token = await gis.currentToken {
			attachmentsURL.formParams.token = token
		}

		var req = try! HTTPClient.Request(url: attachmentsURL, method: .GET)

		var values: [(Int, AttachmentResponse)] = []

		var at = try! await handle(response: gis.client.execute(request: req).get(), decodeType: AttachmentInfosResponse.self)

		for ati in at.attachmentInfos {
			req = try! HTTPClient.Request(url: attachmentsURL + String(ati.id), method: .GET)

			values.append((ati.id, try await handle(response: gis.client.execute(request: req).get(), decodeType: AttachmentResponse.self)))
		}

		for i in 0..<at.attachmentInfos.count {
			for b in values {
				if at.attachmentInfos[i].id == b.0 {
					at.attachmentInfos[i].data = b.1.attachment
				}
			}
		}

		return at.attachmentInfos
	}

	/// Add an `Attachment` to this `Feature`.
	/// - Parameters:
	///   - attachment: The data to upload.
	///   - name: The name of the attachment. This MUST include the extension.
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKDataError`.
	/// - Returns: A `JSON` response that describes whether the request succeeded or failed.
	public func addAttachment(data: Data, name: String, gis: GIS, mimeType: MediaType? = nil) async throws -> JSON {
		var parts: [Subpart] = []

		parts.append(
			Subpart(
				contentDisposition: try .init(uncheckedName: "file", uncheckedFilename: name),
				contentType: mimeType != nil ? .init(mediaType: mimeType!) : nil,
				body: data
			)
		)

		if let token = await gis.currentToken {
			parts.append(Subpart(contentDisposition: ContentDisposition(name: "token"), body: Data(token.utf8)))
		}

		let multipart = MultipartFormData(body: parts)

		var newURL = self.fullURL + "addAttachment"
		newURL.formParams.f = "json"

		if let token = await gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! HTTPClient.Request(
			url: newURL,
			method: .POST,
			headers: ["Content-Type": "multipart/form-data; boundary=\"\(multipart.boundary)\""],
			body: .data(multipart.httpBody)
		)

		return try await handle(response: gis.client.execute(request: req).get(), decodeType: JSON.self)
	}

	/// Deletes all the `Attachment`s whose ID is contained within `ids`.
	/// - Parameters:
	///   - ids: The IDs of the `Attachment`s you wish to delete.
	///   - gis: The `GIS` to use to authenticate.
	/// - Returns: A `JSON` response that describes whether the request succeeded or failed.
	public func deleteAttachments(ids: [Int], gis: GIS) async throws -> JSON {
		let stringIDs = ids.map(String.init(_:)).joined(separator: ",")

		var newURL = self.fullURL + "deleteAttachments"
		newURL.formParams += ["f": "json", "attachmentIds": stringIDs]

		if let token = await gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! HTTPClient.Request(url: newURL, method: .POST)

		return try await handle(response: gis.client.execute(request: req).get(), decodeType: JSON.self)
	}
}