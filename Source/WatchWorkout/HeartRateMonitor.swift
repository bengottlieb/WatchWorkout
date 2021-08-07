//
//  HeartRate.swift
//
//  Created by Ben Gottlieb on 8/1/21.
//

import HealthKit
import Suite


#if os(watchOS)
public class HeartRateMonitor: ObservableObject {
	public static let instance = HeartRateMonitor()
	
	public var currentHeartRate = CurrentValueSubject<Int?, Never>(nil)
	public var history: [TimeStampedHeartRate] = []
	
	public static let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
	public static let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
	
	public func history(overLast interval: TimeInterval) -> Double? {
		guard history.isNotEmpty else { return nil }
		
		var total: Double = 0
		var count = 0
		
		for rate in history.reversed() {
			if abs(rate.date.timeIntervalSinceNow) > interval { break }
			count += 1
			total += rate.rate
		}
		
		if count == 0 { return nil }
		return total / Double(count)
	}
	
	func set(heartRate rate: Double) {
		let roundedValue = round(rate)

		DispatchQueue.main.async {
			self.objectWillChange.send()
			self.history.append(TimeStampedHeartRate(rate: rate))
			self.currentHeartRate.send(Int(roundedValue))
		}
	}
}

extension HeartRateMonitor {
	public struct TimeStampedHeartRate {
		public var date = Date()
		public var rate: Double
	}
}
#endif
