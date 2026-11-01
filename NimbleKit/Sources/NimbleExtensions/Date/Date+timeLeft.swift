//
//  Date+timeLeft.swift
//  AshteMobile
//
//  Created by samara on 16.04.2025.
//

import Foundation
import SwiftUI

extension Date {
	public struct ExpirationInfo {
		public let formatted: String
		public let color: Color
		public let icon: String
	}
	
	/// Gathers data for `ExpirationInfo`
	/// - Parameter now: Date
	/// - Returns: `ExpirationInfo`
	public func expirationInfo(from now: Date = .now) -> ExpirationInfo {
		let timeLeft = self.timeIntervalSince(now)
		
		guard timeLeft > 0 else {
			return ExpirationInfo(
				formatted: .localized("Expired"),
				color: .gray,
				icon: "xmark.octagon"
			)
		}
		
		let daysLeft = Int(timeLeft / 86400)
		let color = Color.expiration(days: daysLeft)
		
		let timeString: String
		if timeLeft < 3600 {
			let minutes = max(1, Int(timeLeft / 60))
			timeString = .localized(minutes == 1 ? "%lld minute" : "%lld minutes", arguments: minutes)
		} else if timeLeft < 86400 {
			let hours = Int(timeLeft / 3600)
			timeString = .localized(hours == 1 ? "%lld hour" : "%lld hours", arguments: hours)
		} else {
			timeString = .localized(daysLeft == 1 ? "%lld day" : "%lld days", arguments: daysLeft)
		}
		
		return ExpirationInfo(
			formatted: timeString,
			color: color,
			icon: "clock"
		)
	}
}
