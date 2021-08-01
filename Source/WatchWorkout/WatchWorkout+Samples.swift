//
//  WatchWorkout+Samples.swift
//
//  Created by Ben Gottlieb on 8/1/21.
//

import HealthKit
import Suite

public extension WatchWorkout {
	func addSleep(_ kind: HKCategoryValueSleepAnalysis, over range: DateInterval? = nil, metadata: [String: Any]? = nil, completion: ErrorCallback? = nil) {
		
		guard let type = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
			completion?(WorkoutError.failedToFetchTypes)
			return
		}
		let start = range?.start ?? startedAt ?? Date(timeIntervalSinceNow: -60)
		let end = range?.end ?? endedAt ?? Date()
		let sample = HKCategorySample(type: type, value: kind.rawValue, start: start, end: end, metadata: metadata)
		
		add(samples: [sample], completion: completion)
	}

	func addCalories(active: Double? = nil, basal: Double? = nil, over range: DateInterval? = nil, metadata: [String: Any]? = nil, completion: ErrorCallback? = nil) {
		var samples: [HKSample] = []
		let start = range?.start ?? startedAt ?? Date(timeIntervalSinceNow: -60)
		let end = range?.end ?? endedAt ?? Date()
		
		if let amount = active {
			guard let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
				completion?(WorkoutError.failedToFetchTypes)
				return
			}
			let quantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: amount)
			let sample = HKCumulativeQuantitySample(type: quantityType, quantity: quantity, start: start, end: end, metadata: metadata)
			samples.append(sample)
		}

		if let amount = basal {
			guard let quantityType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else {
				completion?(WorkoutError.failedToFetchTypes)
				return
			}
			let quantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: amount)
			let sample = HKCumulativeQuantitySample(type: quantityType, quantity: quantity, start: start, end: end, metadata: metadata)
			samples.append(sample)
		}

		add(samples: samples, completion: completion)
	}
	
	func add(samples: [HKSample], completion: ErrorCallback? = nil) {
		guard hasStarted else {
			completion?(WorkoutError.notRunning)
			return
		}
		
		guard samples.isNotEmpty else {
			completion?(nil)
			return
		}

		guard let builder = builder else {
			completion?(WorkoutError.noBuilderAvailable)
			return
		}
		
		builder.add(samples) { success, error in
			if success {
				completion?(nil)
			} else {
				completion?(error ?? WorkoutError.failedToAddSamples)
			}
		}
	}
}
