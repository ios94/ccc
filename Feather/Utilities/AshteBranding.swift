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
	static let defaultCode = "en"

	static let languages: [AshteLanguage] = [
		.init(code: "en", nativeName: "English"),
		.init(code: "ar", nativeName: "العربية"),
		.init(code: "ckb", nativeName: "کوردی")
	]

	static var current: String {
		UserDefaults.standard.string(forKey: storageKey) ?? defaultCode
	}

	/// English text is the key. Other languages are looked up in `table`; missing keys fall back to English.
	static func t(_ key: String) -> String {
		let code = current
		guard code != defaultCode else { return key }
		return table[code]?[key] ?? key
	}

	static func t(_ key: String, _ args: CVarArg...) -> String {
		String(format: t(key), arguments: args)
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
			"Social": "التواصل"
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
			"Social": "تۆڕە کۆمەڵایەتییەکان"
		]
	]
}
