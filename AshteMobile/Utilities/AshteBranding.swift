//
//  AshteBranding.swift
//  AshteMobile
//

import SwiftUI
import ObjectiveC

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
	/// The language the app starts with. English is the default.
	static let defaultCode = "en"

	static let languages: [AshteLanguage] = [
		.init(code: "en", nativeName: "English"),
		.init(code: "ar", nativeName: "العربية"),
		.init(code: "ckb", nativeName: "کوردی")
	]

	/// Arabic and Kurdish (Sorani) are right-to-left, English is left-to-right.
	static var layoutDirection: LayoutDirection {
		["ar", "ckb"].contains(current) ? .rightToLeft : .leftToRight
	}

	static var current: String {
		UserDefaults.standard.string(forKey: storageKey) ?? defaultCode
	}

	/// Locale matching the language chosen inside the app (not the phone language).
	static var locale: Locale { Locale(identifier: current) }

	/// `.lproj` bundle of the chosen language (nil for English / when it does not exist).
	static func languageBundle(for code: String = AshteL10n.current) -> Bundle? {
		guard code != "en",
			  let path = Bundle.main.path(forResource: code, ofType: "lproj") else { return nil }
		return Bundle(path: path)
	}

	/// English text is the key.
	/// Order: small built-in table -> Localizable.xcstrings of the chosen language -> English key.
	static func t(_ key: String) -> String {
		let code = current
		guard code != "en" else { return key }
		if let v = table[code]?[key] { return v }
		if let b = languageBundle(for: code) {
			let v = b.localizedString(forKey: key, value: nil, table: nil)
			if v != key { return v }
		}
		return key
	}

	static func t(_ key: String, _ args: CVarArg...) -> String {
		String(format: t(key), arguments: args)
	}

	/// Call once at launch: makes EVERY `NSLocalizedString` / `.localized()` / `Text("key")`
	/// follow the language chosen inside the app instead of the phone language.
	static func bootstrap() {
		object_setClass(Bundle.main, AshteLocalizedBundle.self)
	}

	private static let table: [String: [String: String]] = [
		"ar": [
			"Today": "اليوم", "Games": "الألعاب", "Apps": "التطبيقات", "Signing": "التوقيع",
			"Search": "بحث", "Settings": "الإعدادات", "Certificates": "الشهادات",
			"Official App Channel": "القناة الرسمية للتطبيق", "Notifications": "الإشعارات",
			"Appearance": "المظهر", "Translation": "الترجمة", "Developer": "المطوّر",
			"Installation Type": "نوع التثبيت", "Install from Server": "التثبيت من السيرفر",
			"Install with idevice": "التثبيت عبر idevice", "Features": "الميزات",
			"Signing Options": "خيارات التوقيع", "Archive & Compression": "الأرشفة والضغط",
			"Installation": "التثبيت", "Reset": "إعادة الضبط",
			"Reset the applications sources, certificates, apps, and general contents.": "إعادة ضبط المصادر والشهادات والتطبيقات والمحتوى العام.",
			"Language": "اللغة", "Choose the app language. English is the default.": "اختر لغة التطبيق. الإنجليزية هي الافتراضية.",
			"Some screens may need the app to be reopened.": "قد تحتاج بعض الشاشات إلى إعادة فتح التطبيق.",
			"More from %@": "المزيد من %@", "Discover your next app": "اكتشف تطبيقك القادم",
			"AshteMobile Pick": "اختيار AshteMobile", "Get": "تنزيل", "Sign with AshteMobile": "توقيع عبر AshteMobile",
			"Social": "التواصل", "My Sources": "مصادري", "Back": "رجوع"
		],
		"ckb": [
			"Today": "ئەمڕۆ", "Games": "یاری", "Apps": "ئەپەکان", "Signing": "واژۆکردن",
			"Search": "گەڕان", "Settings": "ڕێکخستنەکان", "Certificates": "بڕوانامەکان",
			"Official App Channel": "کەناڵی فەرمی ئەپەکە", "Notifications": "ئاگادارکردنەوەکان",
			"Appearance": "ڕووکار", "Translation": "وەرگێڕان", "Developer": "گەشەپێدەر",
			"Installation Type": "جۆری دامەزراندن", "Install from Server": "دامەزراندن لە سێرڤەرەوە",
			"Install with idevice": "دامەزراندن بە idevice", "Features": "تایبەتمەندییەکان",
			"Signing Options": "هەڵبژاردەکانی واژۆ", "Archive & Compression": "ئەرشیف و پەستان",
			"Installation": "دامەزراندن", "Reset": "ڕێکخستنەوە",
			"Reset the applications sources, certificates, apps, and general contents.": "ڕێکخستنەوەی سەرچاوەکان، بڕوانامەکان، ئەپەکان و ناوەڕۆکی گشتی.",
			"Language": "زمان", "Choose the app language. English is the default.": "زمانی ئەپەکە هەڵبژێرە. ئینگلیزی بنەڕەتییە.",
			"Some screens may need the app to be reopened.": "هەندێک شاشە پێویستیان بە کردنەوەی دووبارەی ئەپەکە هەیە.",
			"More from %@": "زیاتر لە %@", "Discover your next app": "ئەپی داهاتووت بدۆزەرەوە",
			"AshteMobile Pick": "هەڵبژاردەی AshteMobile", "Get": "داگرتن", "Sign with AshteMobile": "واژۆکردن بە AshteMobile",
			"Social": "تۆڕە کۆمەڵایەتییەکان", "My Sources": "سەرچاوەکانم", "Back": "گەڕانەوە"
		]
	]
}

// MARK: - Bundle override (follow the in-app language)
private final class AshteLocalizedBundle: Bundle {
	override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
		if let b = AshteL10n.languageBundle() {
			return b.localizedString(forKey: key, value: value, table: tableName)
		}
		// English: use the development-language (en / Base) strings, never the phone language.
		if let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let b = Bundle(path: path) {
			return b.localizedString(forKey: key, value: value, table: tableName)
		}
		return value ?? key
	}
}
