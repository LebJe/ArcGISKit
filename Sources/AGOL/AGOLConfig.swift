//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 12/25/20.
//

import Files
import Foundation

struct AGOLConfig: Codable {
	let userType: UserType
	let username: String?
	let password: String?

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
	return try configFolder().createFileIfNeeded(at: ".agolconfig")
}
