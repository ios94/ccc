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
        NBList(AL("المظهر")) {
            Section {
                Picker(AL("المظهر"), selection: $userInterfaceStyle) {
                    Text(AL("النظام")).tag(UIUserInterfaceStyle.unspecified.rawValue)
                    Text(AL("فاتح")).tag(UIUserInterfaceStyle.light.rawValue)
                    Text(AL("داكن")).tag(UIUserInterfaceStyle.dark.rawValue)
                }
                .pickerStyle(.segmented)
            }

            Section {
                AppearanceTintColorView()
            }
        }
    }
}
