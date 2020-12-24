//
//  main.swift
//  
//
//  Created by Jeff Lebrun on 12/24/20.
//

import Foundation
import ArcGISKit
import GetPass

print("Username: ", terminator: "")
let username = readLine()!

print("Password: ", terminator: "")

var buf = Array<CChar>(repeating: 0, count: 8192)
var size = buf.count

var pointerToPassword = Optional.init(UnsafeMutablePointer(&buf))

my_getpass(&pointerToPassword, &size, stdin)

let password = String(cString: pointerToPassword!)

print()

print(password)

let gis = try GIS(username: username, password: password, url: URL(string: "https://lebrunhs.maps.arcgis.com")!)

print(gis.user!.fullName)
