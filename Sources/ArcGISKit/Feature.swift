//
//  Feature.swift
//  
//
//  Created by Jeff Lebrun on 1/28/21.
//

import Foundation
import AsyncKit
import AsyncHTTPClient
import SwiftyJSON
import CodableWrappers

public struct Feature: Codable, Equatable {
	public init(geometry: Geometry? = nil, attributes: JSON? = nil) {
		self.geometry = geometry
		self.attributes = attributes
	}

	@OmitCoding
	var featureServerURL: URL? = nil

	@OmitCoding
	var featureLayerID: Int? = 0

	public var geometry: Geometry?
	public var attributes: JSON?

	/// The `Attachment`s contained in this `Feature`.
	@OmitCoding
	public var attachments: [Attachment]? = nil

	/// Fetch all the `Attachment`s contained in this `Feature`.
	/// - Parameter gis: The `GIS` to use to authenticate.
	/// - Returns: the array of `Attachment`s.
	public func fetchAttachments(gis: GIS) -> EventLoopFuture<[Attachment]> {
		let attachmentsURL = self.featureServerURL!
			.appendingPathComponent(String(self.featureLayerID!))
			.appendingPathComponent(String(self.attributes!["OBJECTID"].intValue))
			.appendingPathComponent("attachments")

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
}
