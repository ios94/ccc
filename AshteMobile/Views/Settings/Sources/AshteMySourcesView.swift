//
//  AshteMySourcesView.swift
//  AshteMobile
//

import SwiftUI
import CoreData

/// The "My sources" list that used to live in the old settings popup.
struct AshteMySourcesView: View {
	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \AltSource.name, ascending: true)]
	) private var _sources: FetchedResults<AltSource>
	@State private var _isAddingSource = false

	private var _userAddedSourcesOnly: [AltSource] {
		_sources.filter { !ProtectedSourcesVault.isHiddenCoreSource($0) }
	}

	var body: some View {
		List {
			Section {
				Button {
					_isAddingSource = true
				} label: {
					Label(AL("إضافة مصدر (سورس) خاص بك"), systemImage: "plus.circle.fill")
						.font(.body.weight(.semibold))
				}
			} footer: {
				Text(AL("جميع المصادر المضافة هنا محمية ولا يمكن تصدير أو نسخ روابطها."))
					.font(.caption2)
			}

			if !_userAddedSourcesOnly.isEmpty {
				Section(AL("المصادر الإضافية")) {
					ForEach(_userAddedSourcesOnly) { source in
						HStack(spacing: 12) {
							Image(systemName: "shippingbox.fill")
								.font(.system(size: 20))
								.foregroundStyle(AppStoreTheme.dynamicAccent)
								.frame(width: 38, height: 38)
								.background(AppStoreTheme.dynamicAccent.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))

							VStack(alignment: .leading, spacing: 2) {
								Text(source.name ?? AL("مصدر مضاف"))
									.font(.body.weight(.bold))
									.foregroundStyle(.primary)
								Text(AL("مصدر مفعل • الرابط مخفي للحماية"))
									.font(.caption2)
									.foregroundStyle(.secondary)
							}
							Spacer()
						}
						.padding(.vertical, 4)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								Storage.shared.deleteSource(for: source)
							} label: {
								Label(AL("حذف"), systemImage: "trash")
							}
						}
					}
				}
			}
		}
		.navigationTitle(AshteL10n.t("My Sources"))
		.navigationBarTitleDisplayMode(.inline)
		.sheet(isPresented: $_isAddingSource) {
			CustomSafeAddSourceSheet()
		}
	}
}
