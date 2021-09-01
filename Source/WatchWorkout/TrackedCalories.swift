//
//  TrackedCalories.swift
//
//  Created by Ben Gottlieb on 8/12/21.
//

import Foundation
import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
public class TrackedCalories: CustomStringConvertible {
	let queue = DispatchQueue(label: "TrackedCalories", qos: .utility)
	var recorded: [RecordedCalories] = []
	public var total: Double = 0

	struct RecordedCalories {
		let interval: DateInterval
		let quantity: Double

		let minQuantity: Double?
		let maxQuantity: Double?
		let avgQuantity: Double?
		let sumQuantity: Double?
	}

	func track(statistics: HKStatistics) {
		let unit = WatchWorkoutManager.calorieUnit
		if let sum = statistics.sumQuantity()?.doubleValue(for: unit) { total = sum }
		guard let interval = statistics.mostRecentQuantityDateInterval(), let quantity = statistics.mostRecentQuantity()?.doubleValue(for: WatchWorkoutManager.calorieUnit) else { return }
		
		queue.async {
			if self.recorded.contains(where: { $0.interval == interval }) { return }
			self.recorded.append(RecordedCalories(interval: interval, quantity: quantity, minQuantity: statistics.minimumQuantity()?.doubleValue(for: unit), maxQuantity: statistics.maximumQuantity()?.doubleValue(for: unit), avgQuantity: statistics.averageQuantity()?.doubleValue(for: unit), sumQuantity: statistics.sumQuantity()?.doubleValue(for: unit)))
		}
	}
	
	public var description: String {
		var results = "Total: \(total)"
		for record in recorded {
			results += "\n\(record.interval): \(record.quantity)"
			
			if let min = record.minQuantity, let max = record.maxQuantity, let avg = record.avgQuantity {
				results += " \(min) ... \(avg) ... \(max)"
			}
			
			if let sum = record.sumQuantity { results += "[\(sum)]" }
		}
		
		results += "\nTotal Quantity\(recorded.map { $0.quantity }.sum() )"
		results += "\nTotal Min\(recorded.compactMap { $0.minQuantity }.sum() )"
		results += "\nTotal Avg\(recorded.compactMap { $0.avgQuantity }.sum() )"
		results += "\nTotal Max\(recorded.compactMap { $0.maxQuantity }.sum() )"
		results += "\nTotal Sum\(recorded.compactMap { $0.sumQuantity }.sum() )"

		return results
	}
}
#endif
