//
//  HeartRateLabel.swift
//  HeartRateLabel
//
//  Created by Ben Gottlieb on 8/1/21.
//

import SwiftUI

struct HeartRateLabel: View {
	@ObservedObject var monitor = HeartRateMonitor.instance
	
	var rateText: String {
		if let rate = monitor.currentHeartRate.value { return "\(rate)" }
		return "--"
	}
	var body: some View {
		Text(rateText + " ❤️")
			
	}
}

struct HeartRateLabel_Previews: PreviewProvider {
	static var previews: some View {
		HeartRateLabel()
	}
}
