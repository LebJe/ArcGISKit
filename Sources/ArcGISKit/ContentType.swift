//
//  ContentType.swift
//  
//
//  Created by Jeff Lebrun on 1/1/21.
//

import Foundation

public enum ContentType: Equatable {
	public static func == (lhs: ContentType, rhs: ContentType) -> Bool {
		switch lhs {
			case let .featureServer(f):
				if case .featureServer(let f2) = rhs {
					return f == f2
				}
				return false
			default:
				return false
		}
	}

	case featureServer(FeatureServer)
}
