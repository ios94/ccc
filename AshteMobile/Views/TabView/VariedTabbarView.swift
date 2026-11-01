//
//  VariedTabbarView.swift
//  AshteMobile
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct VariedTabbarView: View {
	@AppStorage(AshteL10n.storageKey) private var _language: String = AshteL10n.defaultCode
	
	init() {}
	
	var body: some View {
		Group {
			if #available(iOS 18, *) {
				ExtendedTabbarView()
			} else {
				TabbarView()
			}
		}
		.id(_language)
	}
}
