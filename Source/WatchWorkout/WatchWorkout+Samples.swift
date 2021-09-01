//
//  WatchWorkout+Samples.swift
//
//  Created by Ben Gottlieb on 8/1/21.
//

import HealthKit
import Suite

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
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
		enqueue("add samples") {
			if WatchWorkoutManager.instance.loggingEnabled { logg("Adding samples, Current phase: \(self.phase)") }
			guard self.hasStarted else {
				completion?(WorkoutError.notRunning)
				self.handlePending()
				return
			}
			
			guard samples.isNotEmpty else {
				if WatchWorkoutManager.instance.loggingEnabled { logg("Not Adding samples, no samples") }
				completion?(nil)
				self.handlePending()
				return
			}

			guard let builder = self.builder else {
				completion?(WorkoutError.noBuilderAvailable)
				self.handlePending()
				return
			}
			
			builder.add(samples) { success, error in
				if WatchWorkoutManager.instance.loggingEnabled { logg("Added samples \(samples) \(success) \(error?.localizedDescription ?? "no error")") }
				if success {
					completion?(nil)
				} else {
					completion?(error ?? WorkoutError.failedToAddSamples)
				}
				self.handlePending()
			}
		}
	}
}
#endif
