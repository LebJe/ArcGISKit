//
//  Coders.swift
//
//
//  Created by Jeff Lebrun on 1/28/21.
//

import CodableWrappers
import Foundation

public struct CommaSeparatedCapabilityCoder: StaticCoder {
	public static func decode(from decoder: Decoder) throws -> [Capability] {
		try String(from: decoder)
			.components(separatedBy: ",")
			.map({ Capability(rawValue: $0.lowercased())! })
	}

	public static func encode(value: [Capability], to encoder: Encoder) throws {
		let array = value.map(\.rawValue.capitalized)

		try array.joined(separator: ",").encode(to: encoder)
	}
}
