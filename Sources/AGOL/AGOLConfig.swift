//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import Files
import Foundation

enum ConfigError: Error {
	case noConfigFile
}

let agolConfigFilename = ".agolconfig"

struct AGOLConfig: Codable {
	let userType: UserType
	let username: String?
	let password: String?
	var url: URL = URL(string: "https://arcgis.com")!
	var site: String = "sharing"

	enum UserType: String, Codable, CaseIterable {
		case anonymous, authenticated
	}
}

func configFolder() throws -> Folder {
	let xdgConfigHome = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]

	var configFolder: Folder = .home
	if xdgConfigHome == nil {
		configFolder = try Folder.home.createSubfolderIfNeeded(at: ".config/agol")
	} else {
		configFolder = try Folder.home.subfolder(at: xdgConfigHome!)
		configFolder = try configFolder.createSubfolderIfNeeded(at: "agol")
	}

	return configFolder
}

func configFile() throws -> File {
	return try configFolder().createFileIfNeeded(at: agolConfigFilename)
}

func getConfigFileData() throws -> AGOLConfig {
	do {
		let data = try configFolder().file(at: agolConfigFilename).read()
		return try! JSONDecoder().decode(AGOLConfig.self, from: data)
	} catch {
		throw ConfigError.noConfigFile
	}

}
