// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

public enum Either<Left: Codable & Equatable, Right: Codable & Equatable>: Codable, Equatable {
	case left(Left)
	case right(Right)

	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
			case let (.left(left), .left(left2)):
				return left == left2
			case let (.right(right), .right(right2)):
				return right == right2
			default: return false
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		do {
			self = try .left(container.decode(Left.self))
		} catch DecodingError.typeMismatch {
			self = try .right(container.decode(Right.self))
		}
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
			case let .left(left):
				var container = encoder.singleValueContainer()
				try container.encode(left)
			case let .right(right):
				var container = encoder.singleValueContainer()
				try container.encode(right)
		}
	}
}
