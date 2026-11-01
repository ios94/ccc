//
//  XSignDownloadBanner.swift
//  AshteMobile
//
//  Floating banner at the top of the screen while a store app is downloading:
//  app icon, name, percentage and a ring with a stop button.
//

import SwiftUI

struct XSignDownloadBanner: View {
	@ObservedObject var pipeline: AutoSignPipelineManager

	private var activeKey: String? {
		pipeline.activeStates.first(where: { $0.value == .downloading })?.key
	}

	var body: some View {
		VStack(spacing: 0) {
			if let key = activeKey {
				banner(
					name: pipeline.bannerInfo[key]?.name ?? AshteBranding.appName,
					iconURL: pipeline.bannerInfo[key]?.iconURL,
					percent: pipeline.downloadProgress[key] ?? 0,
					stop: { pipeline.cancelActiveDownload(key: key) }
				)
				.padding(.horizontal, 14)
				.padding(.top, 6)
				.transition(.move(edge: .top).combined(with: .opacity))
			}
			Spacer(minLength: 0)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.animation(.spring(response: 0.45, dampingFraction: 0.82), value: activeKey)
		.environment(\.layoutDirection, .leftToRight)
	}

	private func banner(name: String, iconURL: URL?, percent: Int, stop: @escaping () -> Void) -> some View {
		HStack(spacing: 16) {
			AppStoreIconView(url: iconURL, appName: name, size: 54)

			VStack(alignment: .leading, spacing: 2) {
				Text(name)
					.font(.system(size: 22, weight: .semibold))
					.foregroundStyle(.primary)
					.lineLimit(1)
				Text(verbatim: "\(percent)%")
					.font(.system(size: 21, weight: .regular))
					.monospacedDigit()
					.foregroundStyle(.primary.opacity(0.9))
					.contentTransition(.numericText())
			}

			Spacer(minLength: 8)

			Button(action: stop) {
				ZStack {
					Circle()
						.stroke(Color.primary.opacity(0.18), lineWidth: 6)
					Circle()
						.trim(from: 0, to: max(0.03, CGFloat(percent) / 100))
						.stroke(Color.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
						.rotationEffect(.degrees(-90))
						.animation(.easeOut(duration: 0.25), value: percent)
					RoundedRectangle(cornerRadius: 5, style: .continuous)
						.fill(Color.primary)
						.frame(width: 24, height: 24)
				}
				.frame(width: 60, height: 60)
				.contentShape(Circle())
			}
			.buttonStyle(.plain)
		}
		.padding(.horizontal, 18)
		.padding(.vertical, 12)
		.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 32, style: .continuous)
				.stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
		)
		.shadow(color: .black.opacity(0.18), radius: 18, y: 8)
	}
}
