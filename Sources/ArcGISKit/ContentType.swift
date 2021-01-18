//
//  ContentType.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

import Foundation

/// The type of content owned by you or a `Group` you are in.
public enum ContentType: Equatable {
	public static func == (lhs: ContentType, rhs: ContentType) -> Bool {
		switch lhs {
			case let .featureServer(f, m):
				if case .featureServer(let f2, let m2) = rhs {
					return f == f2 && m == m2
				}
			case let .other(metadata: m):
				if case let .other(m2) = rhs {
					return m == m2
				}
		}

		return false
	}

	case featureServer(featureServer: FeatureServer, metadata: ContentItem)
	case other(metadata: ContentItem)
}
