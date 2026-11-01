//
//  LanguageView.swift
//  AshteMobile
//

import SwiftUI

struct LanguageView: View {
	@AppStorage(AshteL10n.storageKey) private var _language: String = AshteL10n.defaultCode

	var body: some View {
		List {
			Section {
				ForEach(AshteL10n.languages) { language in
					Button {
						_language = language.code
					} label: {
						HStack {
							Text(language.nativeName)
								.foregroundStyle(.primary)
							Spacer()
							if _language == language.code {
								Image(systemName: "checkmark")
									.fontWeight(.semibold)
							}
						}
					}
				}
			} footer: {
				Text(AshteL10n.t("Choose the app language. English is the default.") + "\n" + AshteL10n.t("Some screens may need the app to be reopened."))
			}
		}
		.navigationTitle(AshteL10n.t("Translation"))
		.navigationBarTitleDisplayMode(.inline)
	}
}
