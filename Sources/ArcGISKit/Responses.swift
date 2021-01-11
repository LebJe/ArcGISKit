//
//  Responses.swift
//  
//
//  Created by Jeff Lebrun on 12/22/20.
//

import Foundation
import CodableWrappers

struct RequestTokenResponse: Codable {
	let token: String

	@Immutable @MillisecondsSince1970DateCoding
	var expires: Date
	let ssl: Bool
}
