//
//  Extensions.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation

extension String {
	var urlQueryEncoded: Self {
		self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
	}
}

extension StringProtocol {
	func contains<S: StringProtocol>(oneOf strings: S...) -> Bool {
		for string in strings {
			if !self.contains(string) {
				return false
			}
		}

		return true
	}
}
