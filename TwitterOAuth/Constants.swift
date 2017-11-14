//
//  Constants.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 14.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import Foundation

class Constants
{
	static let consumerKey = "<key>"
	static let consumerSecret = "<secret>"
	static let requestTokenUrl = "https://api.twitter.com/oauth/request_token"
	static let authUrl = "https://api.twitter.com/oauth/authenticate?oauth_token=%@"
	static let accessTokenUrl = "https://api.twitter.com/oauth/access_token"
	static let verifyUrl = "https://api.twitter.com/1.1/account/verify_credentials.json"

	static let urlScheme = "twitteroauth"
	static let urlHost = "authorize"

	// Keys
	static let userIdKey = "user_id"
	static let screenNameKey = "screen_name"
	static let xAuthExpiresKey = "x_auth_expires"
	static let oauthTokenKey = "oauth_token"
	static let oauthVerifierKey = "oauth_verifier"
	static let oauthTokenSecretKey = "oauth_token_secret"
	static let oauthCallbackConfirmedKey = "oauth_callback_confirmed"
}
