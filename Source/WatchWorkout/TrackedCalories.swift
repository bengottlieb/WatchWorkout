//
//  TrackedCalories.swift
//
//  Created by Ben Gottlieb on 8/12/21.
//

import Foundation
import HealthKit

public class TrackedCalories: CustomStringConvertible {
	let queue = DispatchQueue(label: "TrackedCalories", qos: .utility)
	var recorded: [RecordedCalories] = []
	var total: Double = 0
	
	struct RecordedCalories {
		let interval: DateInterval
		let quantity: Double
	}
	
	func track(statistics: HKStatistics) {
		if let sum = statistics.sumQuantity()?.doubleValue(for: WatchWorkoutManager.calorieUnit) { total = sum }
		guard let interval = statistics.mostRecentQuantityDateInterval(), let quantity = statistics.mostRecentQuantity()?.doubleValue(for: WatchWorkoutManager.calorieUnit) else { return }
		
		queue.async {
			if self.recorded.contains(where: { $0.interval == interval }) { return }
			self.recorded.append(RecordedCalories(interval: interval, quantity: quantity))
		}
	}
	
	public var description: String {
		var results = "Total: \(total)"
		for record in recorded {
			results += "\n\(record.interval): \(record.quantity)"
		}
		return results
	}
}
