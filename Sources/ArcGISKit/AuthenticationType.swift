// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

/// The methods to use to authenticate.
public enum AuthenticationType: Sendable, Equatable {
	/// Authenticate using your username and password.
	case credentials(username: String, password: String)

	/// Authenticate anonymously.
	case anonymous

	/// Authenticate using your Client ID and Client Secret.
	case idAndSecret(clientID: String, clientSecret: String, username: String)

	/// Authenticate using a code obtained via a web browser.
	case webBrowser(code: String, clientID: String, clientSecret: String)
}
