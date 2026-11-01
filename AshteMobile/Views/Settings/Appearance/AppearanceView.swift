//
//  AppearanceView.swift
//  AshteMobile
//

import SwiftUI
import NimbleViews
import UIKit

struct AppearanceView: View {
    @AppStorage("AshteMobile.userInterfaceStyle")
    private var userInterfaceStyle: Int = UIUserInterfaceStyle.unspecified.rawValue

    var body: some View {
        NBList(AshteL10n.t("المظهر")) {
            Section {
                Picker(AshteL10n.t("المظهر"), selection: $userInterfaceStyle) {
                    Text(AshteL10n.t("النظام")).tag(UIUserInterfaceStyle.unspecified.rawValue)
                    Text(AshteL10n.t("فاتح")).tag(UIUserInterfaceStyle.light.rawValue)
                    Text(AshteL10n.t("داكن")).tag(UIUserInterfaceStyle.dark.rawValue)
                }
                .pickerStyle(.segmented)
            }

            Section {
                AppearanceTintColorView()
            }
        }
    }
}
