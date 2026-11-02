//
//  InstallProgressView.swift
//  AshteMobile
//
//  Created by samara on 23.04.2025.
//

import SwiftUI
import IDeviceSwift

struct InstallProgressView: View {
	@State private var _isPulsing = false
	
	var app: AppInfoPresentable
	@ObservedObject var viewModel: InstallerStatusViewModel
	
	private let _ringSize: CGFloat = 156
	private let _iconSize: CGFloat = 112
	private let _lineWidth: CGFloat = 8
	
	private var _progress: Double {
		max(0, min(1, viewModel.overallProgress))
	}
	
	private var _isBroken: Bool {
		if case .broken = viewModel.status { return true }
		return false
	}
	
	private var _statusColor: Color {
		if _isBroken { return .red }
		if viewModel.isCompleted { return .green }
		return .accentColor
	}
	
	var body: some View {
		VStack(spacing: 0) {
			_appIcon()
				.scaleEffect(viewModel.isCompleted ? 1.0 : (_isPulsing ? 1.025 : 0.985))
				.animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: _isPulsing)
				.onAppear { _isPulsing = true }
				.padding(.bottom, 20)
			
			_titleBlock()
				.padding(.bottom, 16)
			
			_statusPill()
				.padding(.bottom, 14)
			
			_percentage()
		}
		.padding(.horizontal, 24)
	}
	
	// MARK: Icon + ring
	@ViewBuilder
	private func _appIcon() -> some View {
		ZStack {
			// Soft glow behind the icon
			Circle()
				.fill(_statusColor.opacity(0.16))
				.frame(width: _ringSize + 28, height: _ringSize + 28)
				.blur(radius: 22)
			
			// Ring track
			Circle()
				.stroke(Color.primary.opacity(0.09), lineWidth: _lineWidth)
				.frame(width: _ringSize, height: _ringSize)
			
			// Ring progress
			Circle()
				.trim(from: 0, to: max(0.015, _progress))
				.stroke(
					AngularGradient(
						colors: [_statusColor.opacity(0.35), _statusColor],
						center: .center,
						startAngle: .degrees(0),
						endAngle: .degrees(360 * max(0.015, _progress))
					),
					style: StrokeStyle(lineWidth: _lineWidth, lineCap: .round)
				)
				.rotationEffect(.degrees(-90))
				.frame(width: _ringSize, height: _ringSize)
				.opacity(viewModel.isCompleted || _isBroken ? 0 : 1)
				.animation(.smooth, value: _progress)
				.animation(.smooth, value: viewModel.isCompleted)
			
			// Completed / error full ring
			Circle()
				.stroke(_statusColor.opacity(0.9), lineWidth: _lineWidth)
				.frame(width: _ringSize, height: _ringSize)
				.opacity(viewModel.isCompleted || _isBroken ? 1 : 0)
				.animation(.smooth, value: viewModel.isCompleted)
			
			// App icon
			FRAppIconView(app: app, size: _iconSize)
				.frame(width: _iconSize, height: _iconSize)
				.clipShape(RoundedRectangle(cornerRadius: _iconSize * 0.225, style: .continuous))
				.overlay(
					RoundedRectangle(cornerRadius: _iconSize * 0.225, style: .continuous)
						.stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
				)
				.shadow(color: Color.black.opacity(0.22), radius: 14, y: 8)
			
			// Badge
			if viewModel.isCompleted || _isBroken {
				Image(systemName: _isBroken ? "xmark.circle.fill" : "checkmark.circle.fill")
					.font(.system(size: 34))
					.symbolRenderingMode(.palette)
					.foregroundStyle(.white, _statusColor)
					.background(Circle().fill(Color(UIColor.secondarySystemBackground)).padding(2))
					.offset(x: 46, y: 46)
					.transition(.scale.combined(with: .opacity))
			}
		}
		.frame(width: _ringSize + 8, height: _ringSize + 8)
		.animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isCompleted)
	}
	
	// MARK: App name + version
	@ViewBuilder
	private func _titleBlock() -> some View {
		VStack(spacing: 5) {
			Text(app.name ?? "")
				.font(.title2.weight(.bold))
				.foregroundStyle(.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.7)
			
			let details = [app.version, app.identifier]
				.compactMap { $0 }
				.filter { !$0.isEmpty }
				.joined(separator: " • ")
			
			if !details.isEmpty {
				Text(details)
					.font(.footnote)
					.foregroundStyle(.secondary)
					.lineLimit(1)
					.truncationMode(.middle)
			}
		}
		.multilineTextAlignment(.center)
	}
	
	// MARK: Status pill
	@ViewBuilder
	private func _statusPill() -> some View {
		Label(viewModel.statusLabel, systemImage: viewModel.statusImage)
			.font(.subheadline.weight(.semibold))
			.foregroundStyle(_statusColor)
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.background(_statusColor.opacity(0.14), in: Capsule())
			.overlay(Capsule().stroke(_statusColor.opacity(0.22), lineWidth: 0.8))
			.animation(.smooth, value: viewModel.statusImage)
	}
	
	// MARK: Percentage
	@ViewBuilder
	private func _percentage() -> some View {
		Text(verbatim: "\(Int((_progress * 100).rounded()))%")
			.font(.system(size: 40, weight: .bold, design: .rounded))
			.monospacedDigit()
			.foregroundStyle(.primary)
			.contentTransition(.numericText())
			.animation(.smooth, value: _progress)
			.opacity(_isBroken ? 0.35 : 1)
	}
}
