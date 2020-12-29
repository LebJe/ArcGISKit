//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/29/20.
//

import Foundation
import GetPass

func readPassword(prompt: String = "Password: ") -> String {
	var password = ""
	print(prompt, terminator: "")
	echoOff()
	password = readLine()!
	echoOn()
	print()
	return password
}
