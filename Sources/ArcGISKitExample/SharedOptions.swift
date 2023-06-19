// Copyright (c) 2023 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

import ArgumentParser
import struct Foundation.URL

extension ExamplesCommand {
	struct Options: ParsableArguments {
		@Option(name: [.short, .long], help: "Your ArcGIS username.")
		var username: String

		@Option(name: [.short, .long], help: "Your ArcGIS password.")
		var password: String

		@Option(name: [.short, .long], help: "Your ArcGIS organization URL.", transform: URL.init(string:))
		var organizationURL: URL? = URL(string: "https://arcgis.com")!

		func validate() throws {
			guard organizationURL != nil else {
				throw ValidationError("organization-url must be a valid URL.")
			}
		}
	}
}
