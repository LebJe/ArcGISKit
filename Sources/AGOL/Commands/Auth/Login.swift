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
import Echo
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
			name: [.short, .long],
			help: "ArcGIS Server site."
		)
		var site: String = "sharing"

		@Option(
			name: [.customShort("p"), .long],
			help: "File to read password from.",
			completion: .file(),
			transform: URL.init(fileURLWithPath:)
		)
		var passwordFile: URL? = nil

		@Argument(help: "Your ArcGIS username.")
		var username: String?

		func validate() throws {
			if arcgisServerURL == nil {
				throw ValidationError("ArcGIS Server URL is invalid!".red)
			}
		}

		func run() throws {
			var password: String = ""
			if username != nil {
				if passwordFile == nil {
					password = readPassword()
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
			}

			saveCredentials(username: username, password: password)
		}

		func saveCredentials(username: String?, password: String?) {
			do {
				let gis = try GIS(authType: username == nil && password == nil ? .anonymous : .credentials(username: username!, password: password!), url: arcgisServerURL!, site: site)

				print("Credentials are valid! Saving credentials...".blue)

				if gis.isAnonymous {
					print("You have logged in as an anonymous user. No credentials will be saved.".yellow)
				}

				let config = AGOLConfig(userType: .authenticated, username: username, password: password, url: arcgisServerURL!)
				let data = try JSONEncoder().encode(config)
				let cf = try configFile()

				if try configFolder().containsFile(at: ".agolconfig") {
					do {
						let oldConfigData = try JSONDecoder().decode(AGOLConfig.self, from: try cf.read())
						print("Credentials already exist.".yellow)
						print(
							"Do you want to remove \(oldConfigData.userType == .anonymous ? "\"anonymous user\"" : "\"\(oldConfigData.username!)\"") and replace it with \(config.userType == .anonymous ? "\"anonymous user\"" : "\"\(config.username!)\"") ? [Y(es)/N(o)] ".blue,
							terminator: ""
						)
						switch (readLine() ?? "").lowercased() {
							case "y", "yes":
								break
							case "n", "no":
								print("No credentials were saved.")
								Foundation.exit(0)
							default:
								Foundation.exit(0)
						}
					} catch {
						// config file was empty
					}
				}

				try cf.write(data)

				print("Credentials saved!".green)
			} catch GISError.invalidUsernameOrPassword {
				print("Invalid username or password.".red)
				Foundation.exit(2)
			}
			catch _ as WriteError {
				print("An error occurred while saving credentials".red)
				Foundation.exit(4)
			}
			catch {
				print("An error occurred: \(error)".red)
			}
		}
	}
}
