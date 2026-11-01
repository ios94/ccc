//
//  SettingsView.swift
//  AshteMobile
//

import SwiftUI
import NimbleViews
import UIKit

// MARK: - View
struct SettingsView: View {
	/// `true` when pushed inside an existing NavigationStack (back button + inline title).
	var embedded: Bool = false

	@AppStorage(AshteL10n.storageKey) private var _language: String = AshteL10n.defaultCode
	@AppStorage("AshteMobile.installationMethod") private var _installationMethod: Int = 0
	@State private var _showMethodChangedAlert = false

	// MARK: Body
	var body: some View {
		Group {
			if embedded {
				_content()
					.navigationTitle(AshteL10n.t("Settings"))
					.navigationBarTitleDisplayMode(.inline)
					.toolbar(.visible, for: .navigationBar)
			} else {
				NBNavigationView(AshteL10n.t("Settings")) {
					_content()
				}
			}
		}
		.environment(\.layoutDirection, AshteL10n.layoutDirection)
	}

	@ViewBuilder
	private func _content() -> some View {
		Form {
			_channelSection()
			_installationTypeSection()
			_featuresSection()
			_resetSection()
		}
		.alert(.localized("Advanced Installation Method"), isPresented: $_showMethodChangedAlert) {
			Button(.localized("Switch Back"), role: .destructive) {
				_installationMethod = 0
			}
			Button(.localized("OK"), role: .cancel) {}
		} message: {
			Text(.localized("idevice warning"))
		}
	}
}

// MARK: - Sections
extension SettingsView {
	@ViewBuilder
	private func _channelSection() -> some View {
		Section {
			// Channel / logo
			Button {
				_open(AshteBranding.telegramURL)
			} label: {
				HStack(spacing: 14) {
					_logo(size: 44)
					VStack(alignment: .leading, spacing: 2) {
						Text(AshteBranding.appName)
							.font(.title3.weight(.semibold))
							.foregroundStyle(.primary)
						Text(AshteL10n.t("Official App Channel"))
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					Spacer()
					Image(systemName: "chevron.right")
						.font(.footnote.weight(.semibold))
						.foregroundStyle(.tertiary)
				}
			}

			NavigationLink {
				CertificatesView()
					.navigationTitle(AshteL10n.t("Certificates"))
			} label: {
				Label(AshteL10n.t("Certificates"), systemImage: "checkmark.seal")
			}

			Button {
				if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
					UIApplication.shared.open(url)
				}
			} label: {
				_row(AshteL10n.t("Notifications"), systemImage: "bell")
			}

			NavigationLink {
				AppearanceView()
			} label: {
				Label(AshteL10n.t("Appearance"), systemImage: "paintbrush")
			}

			NavigationLink {
				LanguageView()
			} label: {
				Label(AshteL10n.t("Translation"), systemImage: "globe")
			}

			if let youtube = AshteBranding.youtubeURL {
				Button { _open(youtube) } label: { _row("YouTube", systemImage: "play.rectangle.fill") }
			}

			if AshteBranding.telegramURL != nil {
				Button { _open(AshteBranding.telegramURL) } label: { _row("Telegram", systemImage: "paperplane.fill") }
			}

			Button { _open(AshteBranding.instagramURL) } label: { _row("Instagram", systemImage: "camera") }

			NavigationLink {
				AboutView()
			} label: {
				Label(AshteL10n.t("Developer"), systemImage: "chevron.left.forwardslash.chevron.right")
			}
		}
	}

	@ViewBuilder
	private func _installationTypeSection() -> some View {
		Section {
			Picker(selection: $_installationMethod) {
				Text(AshteL10n.t("Install from Server")).tag(0)
				Text(AshteL10n.t("Install with idevice")).tag(1)
			} label: {
				Label(AshteL10n.t("Installation Type"), systemImage: "arrow.down.circle")
			}
			.pickerStyle(.menu)
			.onChange(of: _installationMethod) { newValue in
				guard newValue == 1 else { return }
				_showMethodChangedAlert = true
			}
		}
	}

	@ViewBuilder
	private func _featuresSection() -> some View {
		NBSection(AshteL10n.t("Features")) {
			NavigationLink(destination: AshteMySourcesView()) {
				Label(AshteL10n.t("My Sources"), systemImage: "shippingbox")
			}
			NavigationLink(destination: ConfigurationView()) {
				Label(AshteL10n.t("Signing Options"), systemImage: "signature")
			}
			NavigationLink(destination: ArchiveView()) {
				Label(AshteL10n.t("Archive & Compression"), systemImage: "archivebox")
			}
			NavigationLink(destination: InstallationView()) {
				Label(AshteL10n.t("Installation"), systemImage: "arrow.down.circle")
			}
		}
	}

	@ViewBuilder
	private func _resetSection() -> some View {
		Section {
			NavigationLink(destination: ResetView()) {
				Label(AshteL10n.t("Reset"), systemImage: "trash")
			}
		} footer: {
			Text(AshteL10n.t("Reset the applications sources, certificates, apps, and general contents."))
		}
	}

	// MARK: Helpers
	@ViewBuilder
	private func _row(_ title: String, systemImage: String) -> some View {
		HStack {
			Label(title, systemImage: systemImage)
				.foregroundStyle(.primary)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(.tertiary)
		}
	}

	@ViewBuilder
	private func _logo(size: CGFloat) -> some View {
		AsyncImage(url: AshteBranding.logoURL) { image in
			image.resizable().scaledToFill()
		} placeholder: {
			FRAppIconView(size: size)
		}
		.frame(width: size, height: size)
		.clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
	}

	private func _open(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url)
	}
}
