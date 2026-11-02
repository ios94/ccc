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
	
	var body: some View {
		VStack(spacing: 16) {
			_appIcon()
				.scaleEffect(viewModel.isCompleted ? 1.0 : (_isPulsing ? 1.03 : 0.98))
				.animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: _isPulsing)
				.onAppear { _isPulsing = true }
			
			VStack(spacing: 4) {
				Text(app.name ?? "")
					.font(.title3.weight(.semibold))
					.foregroundStyle(.primary)
					.lineLimit(1)
				Text(verbatim: "\(Int((viewModel.overallProgress * 100).rounded()))%")
					.font(.subheadline.weight(.medium))
					.monospacedDigit()
					.foregroundStyle(.secondary)
					.contentTransition(.numericText())
					.animation(.smooth, value: viewModel.overallProgress)
			}
		}
		.padding(.horizontal, 24)
	}
	
	@ViewBuilder
	private func _appIcon() -> some View {
		ZStack {
			Circle()
				.stroke(Color.primary.opacity(0.08), lineWidth: 6)
				.frame(width: 132, height: 132)
			
			Circle()
				.trim(from: 0, to: max(0.02, min(1, viewModel.overallProgress)))
				.stroke(
					AngularGradient(
						colors: [Color.accentColor.opacity(0.35), Color.accentColor],
						center: .center,
						startAngle: .degrees(0),
						endAngle: .degrees(360)
					),
					style: StrokeStyle(lineWidth: 6, lineCap: .round)
				)
				.rotationEffect(.degrees(-90))
				.frame(width: 132, height: 132)
				.opacity(viewModel.isCompleted ? 0 : 1)
				.animation(.smooth, value: viewModel.overallProgress)
				.animation(.smooth, value: viewModel.isCompleted)
			
			FRAppIconView(app: app)
				.frame(width: 94, height: 94)
				.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
				.shadow(color: Color.accentColor.opacity(0.25), radius: 14, y: 6)
			
			if viewModel.isCompleted {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 30))
					.symbolRenderingMode(.palette)
					.foregroundStyle(.white, Color.green)
					.background(Circle().fill(Color(UIColor.secondarySystemBackground)).padding(2))
					.offset(x: 38, y: 38)
					.transition(.scale.combined(with: .opacity))
			}
		}
		.animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.isCompleted)
	}
	
	struct PieShape: Shape {
		var progress: Double
		
		func path(in rect: CGRect) -> Path {
			var path = Path()
			let center = CGPoint(x: rect.midX, y: rect.midY)
			let radius = min(rect.width, rect.height) / 2
			let startAngle = Angle(degrees: -90)
			let endAngle = Angle(degrees: -90 + progress * 360)
			
			path.move(to: center)
			path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
			path.closeSubpath()
			
			return path
		}
		
		var animatableData: Double {
			get { progress }
			set { progress = newValue }
		}
	}
}
