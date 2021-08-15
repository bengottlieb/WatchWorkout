//
//  WatchWorkoutManagerOld.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

#if os(watchOS)
public class WatchWorkoutManager: ObservableObject {
	public static let instance = WatchWorkoutManager()

	@Published public var currentWorkout: WatchWorkout?
	public var store = HKHealthStore()
	public var loggingEnabled = false

	public static let activeCalorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
	public static let basalCalorieType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
	public static let calorieUnit = HKUnit.kilocalorie()

	public func recoverActiveWorkout(completion: ((Result<WatchWorkout, Error>) -> Void)? = nil) {
		store.recoverActiveWorkoutSession { session, error in
			if let session = session {
				DispatchQueue.main.async {
					let workout = WatchWorkout(session: session)
					workout.restore { error in
						if let err = error {
							logg(error: error, "Failed to restore a workout from \(session).")
							completion?(.failure(err))
						} else {
							self.currentWorkout = workout
							completion?(.success(workout))
						}
					}
				}
			} else {
				completion?(.failure(WatchWorkout.WorkoutError.noSessionWhenRestoringWorkout))
			}
		}
	}

}
#endif
