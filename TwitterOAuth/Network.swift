//
//  Network.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 14.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import UIKit

class Network
{
	class func doRequest(_ request: URLRequest, completionBlock: @escaping (_ success: Bool, _ data: Data?, _ error: Error?) -> Void)
	{
		guard let requestUrl = request.url else {
			completionBlock(false, nil, nil)
			return
		}
		print("send data request: \(requestUrl.absoluteString)")
		OperationQueue.main.addOperation {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}

		let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
			var success = true
			var errorCode: Int? = nil
			if let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode != 200 && httpResponse.statusCode != 204) {
				errorCode = httpResponse.statusCode
			}

			if error != nil || errorCode != nil {
				success = false
				print("data request error: \(error?.localizedDescription ?? ""), code: \(errorCode ?? 0)")
			}
			OperationQueue.main.addOperation {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			completionBlock(success, data, error)
		}
		task.resume()
	}
}
