//
//  AppDelegate.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 13.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		return true
	}

	// Forward a deeplink to handler
	@available(iOS 9.0, *)
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
		let viewController = window?.rootViewController as? ViewController
		return viewController?.handleCallback(url: url, sourceApplication: sourceApplication) ?? true
	}

	// Legacy code
	@available(iOS, deprecated: 9.0, message: "Please use application:openURL:options:")
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		let viewController = window?.rootViewController as? ViewController
		return viewController?.handleCallback(url: url, sourceApplication: sourceApplication) ?? true
	}

}

