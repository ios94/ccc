//
//  AboutView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews
import NimbleJSON

// MARK: - Extension: Model
extension AboutView {
	struct CreditsModel: Codable, Hashable {
		let name: String
		let desc: String
		let imageUrl: String
	}
}

// MARK: - View
struct AboutView: View {
	@State private var _credits: [CreditsModel] = [
		.init(
			name: "AshteMobile",
			desc: "AshteMobile",
			imageUrl: "https://ashtemobile.site/logo.png"
		)
	]	
	// MARK: Body
	var body: some View {
		NBList(.localized("About")) {
			Section {
				VStack {
					FRAppIconView(size: 72)
					
					Text("AshteMobile")
						.font(.largeTitle)
						.bold()
						.foregroundStyle(Color.accentColor)
					
					HStack(spacing: 4) {
						Text(.localized("Version"))
						Text("1.0")
					}
					.font(.footnote)
					.foregroundStyle(.secondary)
				}
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(EmptyView())
			
			NBSection(.localized("Credits")) {
				ForEach(_credits, id: \.name) { credit in
					_credit(name: credit.name, desc: credit.desc, imageUrl: credit.imageUrl)
				}
				.transition(.slide)
			}
		}
	}
}

// MARK: - Extension: view
extension AboutView {
	@ViewBuilder
	private func _credit(
		name: String,
		desc: String,
		imageUrl: String
	) -> some View {
		HStack {
			if let url = URL(string: imageUrl) {
				FRIconCellView(
					title: name,
					subtitle: desc,
					iconUrl: url,
					size: 45,
					isCircle: true
				)
			}
		}
	}
}
