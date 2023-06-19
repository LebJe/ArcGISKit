// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers
import struct Foundation.Data
import struct Foundation.UUID
import GenericHTTPClient
import JSON
@_exported import MultipartFormData
import WebURL

public struct AGKFeature: Codable, Equatable {
	public init(geometry: AGKGeometry? = nil, attributes: JSON = JSON()) {
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

	public var geometry: AGKGeometry?
	public var attributes: JSON

	/// The `Attachment`s contained in this `Feature`.
	@OmitCoding
	public var attachments: [AGKAttachment]? = nil

	/// Fetch all the `Attachment`s contained in this `Feature`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Returns: the array of `Attachment`s.
	public func fetchAttachments(gis: GIS) async -> Result<[AGKAttachment], AGKError> {
		var attachmentsURL = self.fullURL + "attachments"
		attachmentsURL.formParams.f = "json"

		if let token = await gis.currentToken {
			attachmentsURL.formParams.token = token
		}

		var req = try! GHCHTTPRequest(url: attachmentsURL)

		var values: [(Int, AttachmentResponse)] = []

		let res = await sendAndHandle(request: req, client: gis.httpClient, decodeType: AttachmentInfosResponse.self)
		switch res {
			case var .success(at):
				for ati in at.attachmentInfos {
					req = try! GHCHTTPRequest(url: attachmentsURL + String(ati.id))

					switch await sendAndHandle(request: req, client: gis.httpClient, decodeType: AttachmentResponse.self) {
						case let .success(attachment): values.append((ati.id, attachment))
						case let .failure(error): return .failure(error)
					}
				}

				for i in 0..<at.attachmentInfos.count {
					for b in values {
						if at.attachmentInfos[i].id == b.0 {
							at.attachmentInfos[i].data = b.1.attachment
						}
					}
				}
				return .success(at.attachmentInfos)
			case let .failure(error): return .failure(error)
		}
	}

	/// Add an `Attachment` to this `Feature`.
	/// - Parameters:
	///   - attachment: The data to upload.
	///   - name: The name of the attachment. This MUST include the extension.
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKDataError`.
	/// - Returns: A `JSON` response that describes whether the request succeeded or failed.
	public func addAttachment(data: Data, name: String, gis: GIS, mimeType: MediaType? = nil) async -> Result<JSON, AGKError> {
		var parts: [Subpart] = []

		do {
			try parts.append(
				Subpart(
					contentDisposition: .init(uncheckedName: "file", uncheckedFilename: name),
					contentType: mimeType != nil ? .init(mediaType: mimeType!) : nil,
					body: data
				)
			)
		} catch let error as ContentDisposition.PercentEncodingError {
			return .failure(.requestError(.invalidFilename(name: error.initialValue)))
		} catch { fatalError() }

		if let token = await gis.currentToken {
			parts.append(Subpart(contentDisposition: ContentDisposition(name: "token"), body: Data(token.utf8)))
		}

		let multipart = MultipartFormData(body: parts)

		var newURL = self.fullURL + "addAttachment"
		newURL.formParams.f = "json"

		if let token = await gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! GHCHTTPRequest(
			url: newURL,
			method: .POST,
			headers: ["Content-Type": "multipart/form-data; boundary=\"\(multipart.boundary)\""],
			body: .bytes(Array(multipart.httpBody))
		)

		switch await sendAndHandle(request: req, client: gis.httpClient, decodeType: JSON.self) {
			case let .success(json): return .success(json)
			case let .failure(error): return .failure(error)
		}
	}

	/// Deletes all the `Attachment`s whose ID is contained within `ids`.
	/// - Parameters:
	///   - ids: The IDs of the `Attachment`s you wish to delete.
	///   - gis: The `GIS` to use to authenticate.
	/// - Returns: A `JSON` response that describes whether the request succeeded or failed.
	public func deleteAttachments(ids: [Int], gis: GIS) async throws -> Result<JSON, AGKError> {
		let stringIDs = ids.map(String.init(_:)).joined(separator: ",")

		var newURL = self.fullURL + "deleteAttachments"
		newURL.formParams += ["f": "json", "attachmentIds": stringIDs]

		if let token = await gis.currentToken {
			newURL.formParams.token = token
		}

		let req = try! GHCHTTPRequest(url: newURL, method: .POST)

		switch await sendAndHandle(request: req, client: gis.httpClient, decodeType: JSON.self) {
			case let .success(json): return .success(json)
			case let .failure(error): return .failure(error)
		}
	}
}
