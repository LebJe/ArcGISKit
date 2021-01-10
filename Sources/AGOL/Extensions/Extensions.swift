//
//  Extensions.swift
//  
//
//  Created by Jeff Lebrun on 1/10/21.
//

import Foundation

extension String {
	///
	/// Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
	/// - Parameter length: Desired maximum lengths of a string
	/// - Parameter trailing: A `String` that will be appended after the truncation.

	/// - Returns: `String` object.
	func truncate(length: Int, trailing: String = "…") -> String {
		return (self.count > length) ? self.prefix(length) + trailing : self
	}
}

extension Date {
	var formatted: String {
		let f = DateFormatter()
		f.timeZone = TimeZone(abbreviation: "EST")!
		f.dateStyle = .medium
		f.timeStyle = .short
		return f.string(from: self)
	}
}
