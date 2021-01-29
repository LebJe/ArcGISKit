//
//  Feature.swift
//  
//
//  Created by Jeff Lebrun on 1/28/21.
//

import AsyncKit
import AsyncHTTPClient
import CodableWrappers
import Foundation
import Multipart
import SwiftyJSON
import Swime

public struct Feature: Codable, Equatable {
	public init(geometry: Geometry? = nil, attributes: JSON? = nil) {
		self.geometry = geometry
		self.attributes = attributes
	}

	@OmitCoding
	var featureServerURL: URL? = nil

	@OmitCoding
	var featureLayerID: Int? = 0

	var fullURL: URL {
		self.featureServerURL!
			.appendingPathComponent(String(self.featureLayerID!))
			.appendingPathComponent(String(self.attributes?["OBJECTID"].intValue ?? 0))
	}

	public var geometry: Geometry?
	public var attributes: JSON?

	/// The `Attachment`s contained in this `Feature`.
	@OmitCoding
	public var attachments: [Attachment]? = nil

	/// Fetch all the `Attachment`s contained in this `Feature`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Returns: the array of `Attachment`s.
	public func fetchAttachments(gis: GIS) -> EventLoopFuture<[Attachment]> {
		let attachmentsURL = self.fullURL.appendingPathComponent("attachments")

		let attachmentsURLString = "\(attachmentsURL.absoluteString)?f=json&\(gis.token != nil ? "&token=\(gis.token!)" : "")"

		var req = try! HTTPClient.Request(url: attachmentsURLString, method: .GET)

		return gis.client.execute(request: req).flatMap({
			var at = try! handle(response: $0, decodeType: AttachmentInfosResponse.self)
			var futures: [EventLoopFuture<(Int, AttachmentResponse)>] = []
			at.attachmentInfos.forEach({ ati in
				let url = attachmentsURL.appendingPathComponent(String(ati.id))
				let urlString = "\(url.absoluteString)?f=json&\(gis.token != nil ? "&token=\(gis.token!)" : "")"
				req = try! HTTPClient.Request(url: urlString, method: .GET)

				let future = gis.client.execute(request: req).flatMapThrowing({
					(ati.id, try handle(response: $0, decodeType: AttachmentResponse.self))
				})

				futures.append(future)
			})

			return futures.flatten(on: gis.eventLoopGroup.next()).map({
				for i in 0..<at.attachmentInfos.count {
					for b in $0 {
						if at.attachmentInfos[i].id == b.0 {
							at.attachmentInfos[i].data = b.1.attachment
						}
					}
				}

				return at.attachmentInfos
			})
		})
	}

	/// Add an `Attachment` to this `Feature`.
	/// - Parameters:
	///   - attachment: The data to upload.
	///   - name: The name of the attachment. This MUST include the extension.
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKDataError`.
	/// - Returns: `EventLoopFuture<JSON>`.
	public func addAttachment(data: Data, name: String, gis: GIS) throws -> EventLoopFuture<JSON> {
		var message = Multipart(type: .formData)

		if let token = gis.token {
			message.append(Part.FormData(name: "token", value: token))
		}

		var mime = ""

		if !name.contains(oneOf: ".md", ".txt", ".text") {
			mime = "text/plain"
		} else {
				guard let mimeType = Swime.mimeType(data: data) else {
					throw AGKDataError.unknownMimeType
				}
			mime = mimeType.mime
		}

		message.append(Part.FormData(name: "file", fileData: data, fileName: name, contentType: mime))

		let req = try! HTTPClient.Request(
			url: "\(fullURL.appendingPathComponent("addAttachment").absoluteString)?f=json&\(gis.token != nil ? "&token=\(gis.token!)" : "")",
			method: .POST,
			headers: ["Content-Type": message.headers[0].value],
			body: .data(message.body)
		)

		return gis.client.execute(request: req).flatMapThrowing({
			try handle(response: $0, decodeType: JSON.self)
		})
	}

	/// Deletes all the `Attachment`s whose ID is contained within `ids`.
	/// - Parameters:
	///   - ids: The IDs of the `Attachment`s you wish to delete.
	///   - gis: The `GIS` to use to authenticate.
	/// - Returns: EventLoopFuture<JSON>`.
	public func deleteAttachments(ids: [Int], gis: GIS) -> EventLoopFuture<JSON> {
		let stringIDs = ids.map(String.init(_:)).joined(separator: ",")
		print(stringIDs)
		let req = try! HTTPClient.Request(
			url: fullURL.appendingPathComponent("deleteAttachments").absoluteString + "?f=json\(gis.token != nil ? "&token=\(gis.token!)" : "")&attachmentIds=\(stringIDs.urlQueryEncoded)",
			method: .POST
		)

		return gis.client.execute(request: req).flatMapThrowing({
			try handle(response: $0, decodeType: JSON.self)
		})

	}
}
