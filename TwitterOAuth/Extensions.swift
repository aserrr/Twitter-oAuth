//
//  Extensions.swift
//  TwitterOAuth
//
//  Created by Andrey Seredkin on 13.11.17.
//  Copyright © 2017 MailRu Group. All rights reserved.
//

import UIKit

let kRFC3986PercentEncoding = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"

extension String
{
	/// Parse a query string from URL
	///
	/// - Returns: key-value dictionary
	func parseQuery() -> [String : String] {
		var values: [String : String] = [:]
		let items = self.components(separatedBy: "&")
		for item in items {
			let pair = item.components(separatedBy: "=")
			if pair.count == 2, let key = pair.first, let value = pair.last {
				values[key] = value
			}
		}
		return values
	}

	/// Calculates SHA1 hash
	///
	/// - Parameter key: secret key
	/// - Returns: hashed string
	func sha1(key: String) -> String? {
		guard let cKey = key.cString(using: String.Encoding.utf8), let cData = self.cString(using: String.Encoding.utf8) else { return nil }
		let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)
		let digestLength = Int(CC_SHA1_DIGEST_LENGTH)
		var result = [CUnsignedChar](repeating: 0, count: digestLength)
		CCHmac(algorithm, cKey, Int(strlen(cKey)), cData, Int(strlen(cData)), &result)
		let hmacData: NSData = NSData(bytes: result, length: digestLength)
		let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
		return String(hmacBase64)
	}

	/// Converts String to Bool
	///
	/// - Returns: boolean value if possible
	func toBool() -> Bool? {
		switch self.lowercased() {
			case "true", "yes", "1":
				return true
			case "false", "no", "0":
				return false
			default:
				return nil
		}
	}
}

extension Dictionary where Key: CustomStringConvertible, Value: CustomStringConvertible
{
	/// Converts key-value to query string
	///
	/// - Returns: query string for an URL
	func getQuery() -> String? {
		var query = ""
		for (key, value) in self {
			if let key = key as? String, let value = value as? String {
				if !query.isEmpty {
					query += "&"
				}
				query += key + "=" + value
			}
		}
		return !query.isEmpty ? query : nil
	}
}

extension Dictionary
{
	/// Creates a signature for key-value parameters
	///
	/// - Parameters:
	///   - secret: sectet key
	///   - request: URL request
	///   - tokenSecret: another secret key
	/// - Returns: signature string
	func oauthSignature(secret: String, request: URLRequest, tokenSecret: String? = nil) -> String? {
		var result = ""
		let allowedCharacters = CharacterSet(charactersIn: kRFC3986PercentEncoding)

		let items = self.sorted { (left: (key: Key, value: Value), right: (key: Key, value: Value)) -> Bool in
			var ordered = true
			if let leftKey = left.key as? String, let rightKey = right.key as? String {
				ordered = leftKey < rightKey
			}
			return ordered
		}

		for item in items {
			if let key = item.key as? String, let keyEncoded = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
				let value = item.value as? String, let valueEncoded = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {

				if !result.isEmpty {
					result.append("&")
				}
				result.append(keyEncoded)
				result.append("=")
				result.append(valueEncoded)
			}
		}

		var signature: String?
		if let requestMethod = request.httpMethod,
			let absoluteString = request.url?.absoluteString,
			let requestUrl = absoluteString.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
			let requestData = result.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
			let signingKey = secret.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {

			let baseString = requestMethod.uppercased() + "&" + requestUrl + "&" + requestData
			var key = signingKey + "&"
			if let tokenSecret = tokenSecret {
				key += tokenSecret
			}
			signature = baseString.sha1(key: key)
		}
		return signature
	}

	/// Creates an auth header from key-value parameters
	///
	/// - Returns: auth header string
	func oauthHeader() -> String {
		var result = ""
		let allowedCharacters = CharacterSet(charactersIn: kRFC3986PercentEncoding)

		for item in self {
			if let key = item.key as? String, let keyEncoded = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
				let value = item.value as? String, let valueEncoded = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {

				if !result.isEmpty {
					result.append(",")
				}
				result.append(keyEncoded)
				result.append("=")
				result.append("\"\(valueEncoded)\"")
			}
		}
		return (!result.isEmpty) ? "OAuth \(result)" : ""
	}
}
