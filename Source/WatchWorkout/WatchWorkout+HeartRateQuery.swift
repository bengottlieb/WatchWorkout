//
//  WatchWorkout+HeartRateQuery.swift
//  
//
//  Created by Ben Gottlieb on 10/3/21.
//

import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	var isObservingHeartRate: Bool {
		get { heartRateQuery != nil }
		set { heartRateQuery = nil }
	}
	func startHeartRateQuery() {
		if self.isObservingHeartRate { return }
		let startdate = Date()
		let predicate = HKQuery.predicateForSamples(withStart: startdate, end: nil, options: .strictEndDate)
		let query = HKAnchoredObjectQuery(type: HKQuantityType.heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] query, samples, deleted, anchor, error in
			if let err = error {
				print("*********************** Error while setting up the heart rate: \(err) ***********************")
			}
			self?.heartRateUpdated(with: samples, error: error)
		}
		query.updateHandler = { [weak self] query, samples, deleted, anchor, error in
			if let err = error {
				print("*********************** Error while updating the heart rate: \(err) ***********************")
			}
			self?.heartRateUpdated(with: samples, error: error)
		}
		self.heartRateQuery = query
		self.healthStore.execute(query)
	}
	
	func heartRateUpdated(with samples: [HKSample]?, error: Error?) {
		if let sample = samples?.first as? HKQuantitySample {
			let rate = sample.quantity.doubleValue(for: HKUnit.heartRateUnit)
			HeartRateMonitor.instance.set(heartRate: rate)
		}
	}

	func stopHealthKitQuery() {
		if let query = self.heartRateQuery {
			self.healthStore.stop(query)
			self.heartRateQuery = nil
		}

	}
}
#endif
