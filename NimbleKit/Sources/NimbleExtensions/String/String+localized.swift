//
//  String+localized.swift
//  NimbleKit
//
//  Created by samara on 20.03.2025.
//

import Foundation.NSString
import SwiftUI

/// Lets the host app decide which language `String.localized(...)` resolves to.
public enum NimbleLocalization {
	/// Returns the translated (format) string for a key, in the app's chosen language.
	nonisolated(unsafe) public static var resolver: (@Sendable (String) -> String)?

	static func format(for name: String) -> String {
		if let resolver { return resolver(name) }
		return NSLocalizedString(name, comment: "")
	}
}

extension String {
	// from: https://github.com/NSAntoine/Antoine/blob/main/Antoine/Backend/Extensions/Foundation.swift#L43-L55
	// was given permission to use any code from antoine as I like - thank you Serena!~
	
	static public func localized(_ name: String) -> String {
		NimbleLocalization.format(for: name)
	}
	
	static public func localized(_ name: String, arguments: CVarArg...) -> String {
		String(format: NimbleLocalization.format(for: name), arguments: arguments)
	}
	/// Localizes the current string using the main bundle.
	///
	/// - Returns: The localized string.
	public func localized() -> String {
		String.localized(self)
	}
}

extension LocalizedStringKey {
	static public func localized(_ key: String) -> LocalizedStringKey {
		LocalizedStringKey(key)
	}
}
