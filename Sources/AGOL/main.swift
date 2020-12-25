//
//  main.swift
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//

import Foundation
import ArgumentParser
import ArcGISKit
import GetPass

struct AGOLCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "agol",
		abstract: "Command line tool to interact with ArcGIS Online.",
		version: "0.0.0"
	)

	func run() throws {
		print("Username: ", terminator: "")
		let username = readLine()!

		print("Password: ", terminator: "")

		var buf = Array<CChar>(repeating: 0, count: 8192)
		var size = buf.count

		var pointerToPassword = Optional.init(UnsafeMutablePointer(&buf))

		my_getpass(&pointerToPassword, &size, stdin)

		let password = String(cString: pointerToPassword!)

		print("URL: ", terminator: "")

		let url = readLine()!

		do {
			let gis = try GIS(username: username, password: password, url: URL(string: url)!)
			
			if let user = gis.user {
				print(user.fullName!)
				print(user.email!)
			} else {
				print("Unable to retrieve user.")
				Foundation.exit(1)
			}
		} catch let error as GISError {
			print("Invalid username or password.")
			Foundation.exit(2)
		}
		
	}
}

AGOLCommand.main()
