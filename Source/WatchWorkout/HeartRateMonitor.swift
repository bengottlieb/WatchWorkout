//
//  HeartRate.swift
//
//  Created by Ben Gottlieb on 8/1/21.
//

import HealthKit
import Suite


public class HeartRateMonitor {
	public static let instance = HeartRateMonitor()
	
	public var currentHeartRate = CurrentValueSubject<Int?, Never>(nil)
	
	public static let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
	public static let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
	
	func set(heartRate rate: Double) {
		let roundedValue = round(rate)

		DispatchQueue.main.async {
			self.currentHeartRate.send(Int(roundedValue))
		}
	}
}
