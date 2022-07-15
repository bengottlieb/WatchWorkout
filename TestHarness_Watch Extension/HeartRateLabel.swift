//
//  HeartRateLabel.swift
//  HeartRateLabel
//
//  Created by Ben Gottlieb on 8/1/21.
//

import SwiftUI

#if os(watchOS)
struct HeartRateLabel: View {
	@ObservedObject var monitor = HeartRateMonitor.instance
	
	var rateText: String {
		if let rate = monitor.currentHeartRate.value { return "\(rate)" }
		return "--"
	}
	var body: some View {
		HStack() {
			Text(rateText)
			HeartRateAccessLabel()
		}
	}
}

struct HeartRateLabel_Previews: PreviewProvider {
	static var previews: some View {
		HeartRateLabel()
	}
}

struct HeartRateAccessLabel: View {
	@ObservedObject var monitor = HeartRateMonitor.instance
	
	var body: some View {
		HStack() {
			ZStack() {
				Text("❤️")
					.opacity(monitor.hasHeartRateAccess ? 1 : 0.5)
				if !monitor.hasHeartRateAccess {
					Text(" ⃠")
				}
			}
		}
	}
}
#endif
