//
//  Safari.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 14.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import SafariServices

class Safari
{
	private static var isSafariViewControllerPresented = false

	// In order to avoid error: "Stored properties cannot be marked potentially unavailable with @available"
	private static var _safariViewController: AnyObject?

	@available(iOS 9.0, *)
	private static var safariViewController: SFSafariViewController? {
		get { return _safariViewController as? SFSafariViewController }
		set { _safariViewController = newValue }
	}

	class func openUrl(_ url: URL, controller: UIViewController) {
		if #available(iOS 9.0, *) {
			safariViewController = SFSafariViewController(url: url)
			if let safariViewController = safariViewController {
				self.isSafariViewControllerPresented = true
				controller.present(safariViewController, animated: true, completion: nil)
			}
		} else {
			// Fallback on earlier versions
			UIApplication.shared.openURL(url)
		}
	}

	class func dismissIfNeeded() {
		if #available(iOS 9.0, *), isSafariViewControllerPresented {
			isSafariViewControllerPresented = false
			safariViewController?.dismiss(animated: true, completion: nil)
		}
	}
}
