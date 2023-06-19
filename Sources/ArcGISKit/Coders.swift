// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import CodableWrappers

public struct CommaSeparatedCapabilityCoder: StaticCoder {
	public static func decode(from decoder: Decoder) throws -> [Capability] {
		try String(from: decoder)
			.split(separator: ",")
			.map({ Capability(rawValue: $0.lowercased())! })
	}

	public static func encode(value: [Capability], to encoder: Encoder) throws {
		try value
			.map(\.rawValue.capitalized)
			.joined(separator: ",")
			.encode(to: encoder)
	}
}
