//
//  WatchWorkoutManager.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

public class WatchWorkoutManager: ObservableObject {
	public static let instance = WatchWorkoutManager()

	@Published public var currentWorkout: WatchWorkout?
	public var store = HKHealthStore()
	
	public func recoverActiveWorkout(completion: ErrorCallback? = nil) {
		store.recoverActiveWorkoutSession { session, error in
			if let session = session {
				DispatchQueue.main.async {
					self.currentWorkout = WatchWorkout(session: session)
					self.currentWorkout?.restore { error in
						logg(error: error, "Failed to restore a workout from \(session).")
						completion?(error)
					}
				}
			} else {
				completion?(nil)
			}
		}
	}

}
