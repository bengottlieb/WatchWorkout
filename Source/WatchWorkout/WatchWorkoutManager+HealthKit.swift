//
//  WatchWorkoutManager+HealthKit.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 9/4/21.
//

import Suite
import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkoutManager {
	func checkForHealtkitAccess() {
		hasHealthKitReadAccess = Bundle.main.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") as? String != nil
		hasHealthKitWriteAccess = Bundle.main.object(forInfoDictionaryKey: "NSHealthUpdateUsageDescription") as? String != nil
	}

	func checkForHeartRateAccess() {
		if !hasHealthKitReadAccess { return }
		let heartRateQuery = HKSampleQuery(sampleType: HKQuantityType.heartRateType, predicate: nil, limit: 1, sortDescriptors: nil) { query, samples, error in
			self.store.stop(query)
			DispatchQueue.main.async {
				HeartRateMonitor.instance.hasHeartRateAccess = samples.isNotEmpty
			}
		}
		store.execute(heartRateQuery)
	}

	func authorizeHealthKit(completion: @escaping ErrorCallback) {
		if !hasHealthKitWriteAccess || !hasHealthKitReadAccess {
			print("##### No Access to HealthKit. Make sure your plist has the appropriate keys: NSHealthShareUsageDescription and NSHealthUpdateUsageDescription. #####")
			fatalError()
		}

		self.store.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
			if !success {
				print("### Failed to authorize health kit")
				completion(error)
			} else {
				self.checkForHeartRateAccess()
				completion(nil)
			}
		}

	}
}
#endif
