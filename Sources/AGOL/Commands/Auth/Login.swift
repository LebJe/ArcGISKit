//
//  Login.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import ArcGISKit
import ArgumentParser
import Files
import Foundation
import GetPass
import Rainbow

extension AGOLCommand.Auth {
	struct Login: ParsableCommand {
		static var configuration: CommandConfiguration = CommandConfiguration(abstract: "Log in to ArcGIS Online.")

		@Option(
			name: [.customShort("u"), .long],
			help: "ArcGIS Server URL.",
			transform: URL.init(string:)
		)
		var arcgisServerURL: URL? = URL(string: "https://arcgis.com")!

		@Option(
			name: [.customShort("p"), .long],
			help: "File to read password from.",
			completion: .file(),
			transform: URL.init(fileURLWithPath:)
		)
		var passwordFile: URL? = nil

		@Argument(help: "Your ArcGIS username.")
		var username: String

		func validate() throws {
			if arcgisServerURL == nil {
				throw ValidationError("ArcGIS Server URL is invalid!")
			}
		}

		func run() throws {
			var password: String = ""

			if passwordFile == nil {
				print("Password: ", terminator: "")

				var buf = Array<CChar>(repeating: 0, count: 8192)
				let size = buf.count

				var pointerToPassword = Optional(UnsafeMutablePointer(&buf))

				"*".withCString({ p in
					_ = getpasswd(&pointerToPassword, size, Int32(p.pointee), stdin)
				})

				password = String(cString: pointerToPassword!)
				print()
			} else {
				if
					let data = FileManager.default.contents(atPath: passwordFile!.absoluteString),
					let p = String(data: data, encoding: .utf8)
				{
					password = p
				} else {
					print("Invalid password file. Make sure it exists and isn't corrupted.")
					Foundation.exit(3)
				}
			}

			saveCredentials(username: username, password: password)
		}

		func saveCredentials(username: String?, password: String?) {
			do {
				let gis = try GIS(username: username, password: password, url: arcgisServerURL!)

				print("Credentials are valid! Saving credentials...".blue)

				if gis.isAnonymous {
					print("You have logged in as an anonymous user. No credentials will be saved.".blue)
				}

				let config = AGOLConfig(userType: .authenticated, username: username, password: password)
				let data = try JSONEncoder().encode(config)
				let cf = try configFile()

				if try configFolder().containsFile(at: ".agolconfig") {
					let oldConfigData = try JSONDecoder().decode(AGOLConfig.self, from: try cf.read())
					print(
						"Are you sure you want to remove \(oldConfigData.userType == .anonymous ? "\"anonymous user\"" : "\"\(oldConfigData.username!)\"") and replace it with \(config.userType == .anonymous ? "\"anonymous user\"" : "\"\(config.username!)\"") ? [Y(es)/N(o)] ".blue,
						terminator: ""
					)
					switch (readLine() ?? "").lowercased() {
						case "y":
							break
						case "yes":
							break
						case "n":
							Foundation.exit(0)
						case "no":
							Foundation.exit(0)
						default:
							Foundation.exit(0)
					}

				}

				try cf.write(data)

				print("Credentials saved!".green)
			} catch _ as GISError {
				print("Invalid username or password.")
				Foundation.exit(2)
			}
			catch _ as WriteError {
				print("An error occurred while saving credentials")
				Foundation.exit(4)
			}
			catch {

			}
		}
	}
}
