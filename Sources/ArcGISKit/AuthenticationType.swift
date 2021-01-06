//
//  AuthenticationType.swift
//  
//
//  Created by Jeff Lebrun on 1/5/21.
//

/// The methods to use to authenticate.
public enum AuthenticationType {

	/// Authenticate using your username and password.
	case credentials(username: String, password: String)

	/// Authenticate anonymously.
	case anonymous

	/// Authenticate using a code obtained via a web browser.
	case webBrowser(clientID: String, clientSecret: String)
}
