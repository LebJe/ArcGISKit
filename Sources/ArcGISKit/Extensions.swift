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
