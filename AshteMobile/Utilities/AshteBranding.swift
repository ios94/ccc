//
//  AshteBranding.swift
//  AshteMobile
//

import SwiftUI

// MARK: - Branding (name, logo, social links)
enum AshteBranding {
	static let appName = "AshteMobile"
	static let logoURL = URL(string: "https://ashtemobile.site/a.png")
	static let telegramURL = URL(string: "https://t.me/ashtemobile")
	static let instagramURL = URL(string: "https://www.instagram.com/ashtemobile")
	/// Put your YouTube channel link here (e.g. URL(string: "https://youtube.com/@yourchannel")).
	/// While it is `nil` the YouTube row is hidden.
	static let youtubeURL: URL? = nil
}

// MARK: - Languages (English first, the user can switch)
struct AshteLanguage: Identifiable, Hashable {
	let code: String
	let nativeName: String
	var id: String { code }
}

enum AshteL10n {
	static let storageKey = "ashtemobile.language"
	/// The language the app starts with before the user picks one ("en", "ar" or "ckb").
	static let defaultCode = "ar"

	static let languages: [AshteLanguage] = [
		.init(code: "en", nativeName: "English"),
		.init(code: "ar", nativeName: "العربية"),
		.init(code: "ckb", nativeName: "کوردی")
	]

	/// Arabic and Kurdish (Sorani) are right-to-left, English is left-to-right.
	static var layoutDirection: LayoutDirection {
		isRightToLeft ? .rightToLeft : .leftToRight
	}

	static var isRightToLeft: Bool {
		["ar", "ckb"].contains(current)
	}

	static var current: String {
		let code = UserDefaults.standard.string(forKey: storageKey) ?? defaultCode
		return languages.contains(where: { $0.code == code }) ? code : defaultCode
	}

	/// Locale matching the selected app language (used for SwiftUI's own strings and formatting).
	static var locale: Locale {
		Locale(identifier: current)
	}

	/// Translates `key` into the selected language.
	///
	/// The key can be an English text (the original keys) or an Arabic text (the original
	/// hard-coded strings). Any key that has no translation falls back to itself.
	static func t(_ key: String) -> String {
		translate(key, to: current)
	}

	static func t(_ key: String, _ args: CVarArg...) -> String {
		String(format: t(key), arguments: args)
	}

	static func translate(_ key: String, to code: String) -> String {
		let tables = AshteTranslations.shared
		switch code {
		case "en":  return tables.en[key] ?? key
		case "ar":  return tables.ar[key] ?? key
		case "ckb": return tables.ckb[key] ?? key
		default:    return key
		}
	}

	/// Routes NimbleKit's `String.localized(...)` through the in-app language,
	/// so every screen follows the language picked inside the app (not the iPhone language).
	static func install() {
		NimbleLocalization.resolver = { key in AshteL10n.t(key) }
	}
}
