//
//  FeatureServer.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import AsyncHTTPClient
import AsyncKit
import Foundation
import NIO

/// A `FeatureServer` manages `FeatureService`s.
public struct FeatureServer: Equatable {
	public static func == (lhs: FeatureServer, rhs: FeatureServer) -> Bool {
		lhs.url == rhs.url
	}

	public let url: URL
	var gis: GIS

	public struct LayerQuery {
		public let whereClause: String
		public let layerID: String

		public init(whereClause: String, layerID: String) {
			self.whereClause = whereClause
			self.layerID = layerID
		}
	}

	/// Feature Server
	/// - Parameters:
	///   - url: The URL to the Feature Server, e.g: "https://machine.domain.com/webadaptor/rest/services/ServiceName/FeatureServer"
	///   - gis: The `GIS` to use to authenticate.
	/// - Throws: `AGKRequestError`.
	public init(url: URL, gis: GIS) throws {
		self.url = url
		self.gis = gis
	}

	/// Fetches the `FeatureService` managed by this `FeatureServer`.
	/// - Throws: `AGKRequestError`.
	/// - Returns: The fetched `FeatureService`.
	public func fetchFeatureService() throws -> EventLoopFuture<FeatureService> {
		try self.gis.fetchToken().flatMap({
			let req = try! HTTPClient.Request(
				url: "\(self.url.absoluteString)?f=json\(self.gis.token != nil ? "&token=\(self.gis.token!)" : "")",
				method: .GET
			)

			return self.gis.client.execute(request: req).flatMapThrowing({
				try handle(response: $0, decodeType: FeatureService.self)
			})
		})
	}

	/// Query the `FeatureServer`.
	/// - Parameter layerQueries: The queries you want to perform.
	/// - Returns: An `Array` of `FeatureLayer`s.
	/// - Throws: `AGKRequestError`.
	public func query(layerQueries: [Self.LayerQuery]) throws -> EventLoopFuture<[FeatureLayer]> {
		try self.gis.fetchToken().flatMap({
			let layerQueriesDict = layerQueries.map({ ["layerId": $0.layerID, "where": $0.whereClause, "outfields": "*"] })

			let req = try! HTTPClient.Request(
				url: "\(self.url.appendingPathComponent("query").absoluteString)?f=json&layerDefs=\(String(data: try! JSONEncoder().encode(layerQueriesDict), encoding: .utf8)!.urlQueryEncoded)\(self.gis.token != nil ? "&token=\(self.gis.token!)" : "")",
				method: .GET
			)

			return self.gis.client.execute(request: req)
				.flatMap({ res in
					var qr = try! handle(response: res, decodeType: QueryResponse.self)

					var futures: [EventLoopFuture<(Int, Int, AttachmentInfo)>] = []

					qr.layers.forEach({ l in
						for i in 0..<l.features.count {
							let attachmentsURL = self.url
								.appendingPathComponent("\(l.id)")
								.appendingPathComponent("\(i)")
								.appendingPathComponent("attachments")

							let r = try! HTTPClient.Request(
								url: "\(attachmentsURL.absoluteString)?f=json\(self.gis.token != nil ? "&token=\(self.gis.token!)" : "")",
								method: .GET
							)
							let future = self.gis.client.execute(request: r).map({
								(l.id, i, try! handle(response: $0, decodeType: AttachmentInfo.self))
							})

							futures.append(future)
						}
					})


					return futures.flatten(on: self.gis.client.eventLoopGroup.next())
						.flatMap({ res in
							var moreFutures: [EventLoopFuture<(Int, QueryAttachmentResponse)>] = []

							for i in 0..<qr.layers.count {
								for j in 0..<qr.layers[i].features.count {
									for k in 0..<res.count {
										if qr.layers[i].id == res[k].0 && j == res[k].1 {
											qr.layers[i].features[j].attachments = []
											for attachment in res[k].2.attachmentInfos {
												qr.layers[i].features[j].attachments?.append(attachment)
												
												let attachmentURL = self.url
													.appendingPathComponent("\(qr.layers[i].id)")
													.appendingPathComponent("\(j)")
													.appendingPathComponent("attachments")
													.appendingPathComponent("\(attachment.id)")

												let request = try! HTTPClient.Request(
													url: "\(attachmentURL.absoluteString)?f=json\(self.gis.token != nil ? "&token=\(self.gis.token!)" : "")",
													method: .GET
												)

												let future = self.gis.client.execute(request: request).map({
													(attachment.id, try! handle(response: $0, decodeType: QueryAttachmentResponse.self))
												})

												moreFutures.append(future)
											}
										}
									}
								}
							}

							return moreFutures.flatten(on: self.gis.client.eventLoopGroup.next())
								.map({ dataArray in
									for i in 0..<qr.layers.count {
										for j in 0..<qr.layers[i].features.count {
											for k in 0..<(qr.layers[i].features[j].attachments ?? []).count {
												for data in dataArray {
													if (qr.layers[i].features[j].attachments ?? Array<Attachment>())[k].id == data.0 {
														qr.layers[i].features[j].attachments![k].data = data.1.Attachment
													}
												}
											}
										}
									}
									
									return qr.layers
							})
					})
				})
		})
	}

	/// Deletes `features` from the `FeatureLayer` with the id of `id`.
	///
	/// To delete the first feature from the first layer, you could write:
	///	```swift
	///	let layers = try myFeatureServer
	///		.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///		.wait()
	/// let feature = layers[0].features[0]
	///	let res = try myFeatureServer
	///		.delete([feature.attributes!["OBJECTID"].intValue], from: String(layers[0].id))
	///		.wait()
	///	```
	///
	/// - Parameters:
	///   - featureIDs: The ID of the `Feature`s you wish to delete.
	///   - id: The ID of the `FeatureLayer` you wish to delete the features from.
	/// - Throws: `AGKRequestError`
	/// - Returns: `EventLoopFuture<[EditResponse]>`.
	public func delete(_ featureIDs: [Int], from id: String) throws -> EventLoopFuture<[EditResponse]> {
		try self.edit([.init(id: id, deletes: featureIDs)])
	}

	/// Adds `features` to the `FeatureLayer` with the id of `id`.
	///
	/// To add a feature to the first layer, you could write:
	///	```swift
	///	let layers = try myFeatureServer
	///		.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///		.wait()
	/// var attributes = JSON()
	/// attributes["Greeting"] = "Hi!"
	///
	/// let feature = Feature(geometry: Geometry(x: 0.0, y: 0.0, rings: nil), attributes: attributes)
	///
	/// let res = try myFeatureServer.add([feature], to: "0").wait()
	///	```
	///
	/// - Parameters:
	///   - features: The `Feature`s you wish to add.
	///   - id: The ID of the `FeatureLayer` you wish to add the `features` to.
	/// - Throws: `AGKRequestError`
	/// - Returns: `EventLoopFuture<[EditResponse]>`.
	public func add(_ features: [Feature], to id: String) throws -> EventLoopFuture<[EditResponse]> {
		try self.edit([.init(id: id, adds: features)])
	}

	/// Updates `features` in the `FeatureLayer` with the id of `id`.
	///
	/// To change the value of `Greeting` to "Hi!", you could write:
	///	```swift
	///	let layers = try myFeatureServer
	///		.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")])
	///		.wait()
	///
	/// var feature = layers[0].features[0]
	/// feature.attributes!["Greeting"] = "Hi!"
	/// let res = try myFeatureServer.update([feature], in: "0").wait()
	///	```
	///
	/// - Parameters:
	///   - features: The `Feature`s you wish to update.
	///   - id: The ID of the `FeatureLayer` that contains the `Feature`s you wish to update.
	/// - Throws: `AGKRequestError`
	/// - Returns: `EventLoopFuture<[EditResponse]>`.
	public func update(_ features: [Feature], in id: String) throws -> EventLoopFuture<[EditResponse]> {
		try self.edit([.init(id: id, updates: features)])
	}

	/// Edit the attributes in the `FeatureLayer`s that are contained within this `FeatureServer`.
	///
	/// To change `Greeting` to "Hello", you could write:
	///
	///	```swift
	///	let layers = try myFeatureServer.query(layerQueries: [.init(whereClause: "1=1", layerID: "0")]).wait()
	/// var feature = layers[0].features[0]
	/// feature.attributes!["Greeting"] = "Hello!"
	///	let res = myFeatureServer.edit([A(id: "0", updates: [feature])]).wait()
	///	```
	///
	/// - Parameter a: The values you wish to edit, delete, or add.
	/// - Throws: `AGKRequestError`.
	/// - Returns: `EventLoopFuture<[EditResponse]>`
	func edit(_ a: [A]) throws -> EventLoopFuture<[EditResponse]> {
		try self.gis.fetchToken().flatMap({ _ in
			var req = try! HTTPClient.Request(
				url: url.appendingPathComponent("applyEdits").absoluteString,
				method: .POST
			)

			let d = try! JSONEncoder().encode(a)

			req.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")

			req.body = .string(
				"""
			f=json&edits=\(String(data: d, encoding: .utf8)!.urlQueryEncoded)\(gis.token != nil ? "&token=\(gis.token!)" : "")
			"""
			)

			return gis.client.execute(request: req).map({ res in
				return try! handle(response: res, decodeType: [EditResponse].self)
			})
		})

	}
}

struct A: Codable {
	let id: String
	var updates: [Feature] = []
	var deletes: [Int] = []
	var adds: [Feature] = []
}

public struct EditResponse: Codable {
	public let id: Int
	public let addResults: [EditResult]?
	public let updateResults: [EditResult]?
	
}

public struct EditResult: Codable {
	public let objectId: Int
	public let globalId: String
	public let success: Bool
}
