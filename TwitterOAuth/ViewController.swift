//
//  Constants.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 13.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet weak var tokenLabel: UILabel!
	@IBAction func authorize(_ sender: UIButton) {
		if let tokenUrl = URL(string: Constants.requestTokenUrl) {
			// Request a token
			print("request auth token")
			var request = URLRequest(url: tokenUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
			request.httpMethod = "POST"

			var headers = [
				"oauth_consumer_key": Constants.consumerKey,
				"oauth_nonce": UUID().uuidString,
				"oauth_signature_method": "HMAC-SHA1",
				"oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
				"oauth_version": "1.0",
				"oauth_callback": "\(Constants.urlScheme)://\(Constants.urlHost)/"
			]
			if let signature = headers.oauthSignature(secret: Constants.consumerSecret, request: request) {
				headers["oauth_signature"] = signature
			}

			request.addValue(headers.oauthHeader(), forHTTPHeaderField: "Authorization")

			Network.doRequest(request) { (success: Bool, data: Data?, error: Error?) in
				if success, let data = data, let response = String(data: data, encoding: .utf8) {
					let values = response.parseQuery()
					let oauthToken = values[Constants.oauthTokenKey] ?? ""
					let oauthCallbackConfirmed = values[Constants.oauthCallbackConfirmedKey] ?? ""

					// Open web view
					if !oauthToken.isEmpty,
						let callbackConfirmed = oauthCallbackConfirmed.toBool(), callbackConfirmed,
						let authUrl = URL(string: String(format:Constants.authUrl, oauthToken)) {

						OperationQueue.main.addOperation {
							Safari.openUrl(authUrl, controller: self)
						}
						
					} else {
						print("Incorrect URL or token")
					}
				} else if let error = error {
					print("auth token request error: \(error)")
				}
			}
		}
	}

	func handleCallback(url: URL, sourceApplication: String?) -> Bool {

		Safari.dismissIfNeeded()

		// Parse a deeplink
		if url.scheme == Constants.urlScheme, url.host == Constants.urlHost,
			let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {

			if let oauthToken = queryItems.filter({$0.name == Constants.oauthTokenKey}).first?.value,
				let oauthVerifier = queryItems.filter({$0.name == Constants.oauthVerifierKey}).first?.value,
				let tokenUrl = URL(string: Constants.accessTokenUrl),
				let httpBody = ["oauth_verifier": oauthVerifier].getQuery()?.data(using: .utf8) {

				// request access token
				var request = URLRequest(url: tokenUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
				request.httpMethod = "POST"
				request.httpBody = httpBody

				var headers = [
					"oauth_consumer_key": Constants.consumerKey,
					"oauth_nonce": UUID().uuidString,
					"oauth_signature_method": "HMAC-SHA1",
					"oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
					"oauth_version": "1.0",
					"oauth_token": oauthToken,
					"oauth_verifier": oauthVerifier
				]
				if let signature = headers.oauthSignature(secret: Constants.consumerSecret, request: request) {
					headers["oauth_signature"] = signature
				}
				request.addValue(headers.oauthHeader(), forHTTPHeaderField: "Authorization")

				Network.doRequest(request) { (success: Bool, data: Data?, error: Error?) in
					if success, let data = data, let response = String(data: data, encoding: .utf8) {
						let values = response.parseQuery()
						let oauthToken = values[Constants.oauthTokenKey] ?? ""
						let oauthTokenSecret = values[Constants.oauthTokenSecretKey] ?? ""
						let xAuthExpires = values[Constants.xAuthExpiresKey] ?? ""

						if !oauthToken.isEmpty, let verifyUrl = URL(string: Constants.verifyUrl) {
							let request = URLRequest(url: verifyUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
							var headers = [
								"oauth_callback": "\(Constants.urlScheme)://\(Constants.urlHost)/",
								"oauth_consumer_key": Constants.consumerKey,
								"oauth_nonce": UUID().uuidString,
								"oauth_signature_method": "HMAC-SHA1",
								"oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
								"oauth_token": oauthToken,
								"oauth_version": "1.0"
							]
							if let signature = headers.oauthSignature(secret: Constants.consumerSecret, request: request, tokenSecret: oauthTokenSecret) {
								headers["oauth_signature"] = signature
							}
							let oauthHeader = headers.oauthHeader()
							print("SUCCESS")
							print("oAuthHeader: \(oauthHeader), expires: \(xAuthExpires)")
							OperationQueue.main.addOperation {
								self.tokenLabel.text = oauthHeader
							}
						} else {
							print("Incorrect URL or token")
						}
					} else if let error = error {
						print("auth token request error: \(error)")
					}
				}
			} else {
				print("Invalid token")
			}
		}
		return true
	}

}
