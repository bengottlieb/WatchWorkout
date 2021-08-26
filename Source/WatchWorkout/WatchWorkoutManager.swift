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

	@Published public var currentWorkout: WatchWorkout? { didSet {
		if loggingEnabled {
			print("### Watch Workout set to \(currentWorkout?.description ?? "none")")
		}
	}}
	public var store = HKHealthStore()
	public var loggingEnabled = false

	public static let activeCalorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
	public static let basalCalorieType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
	public static let calorieUnit = HKUnit.kilocalorie()
	private var endingSession: HKWorkoutSession?
	private var inProgressWorkouts: [WatchWorkout] = []
	private let inProgressQueue = DispatchQueue(label: "inProgressWatchWorkouts")

	internal func holdOnTo(_ workout: WatchWorkout) {
		inProgressQueue.async {
			if self.inProgressWorkouts.firstIndex(of: workout) == nil {
				self.inProgressWorkouts.append(workout)
			}
		}
	}

	internal func finished(with workout: WatchWorkout) {
		inProgressQueue.async {
			while let index = self.inProgressWorkouts.firstIndex(of: workout) {
				self.inProgressWorkouts.remove(at: index)
			}
		}
	}

	func end(_ session: HKWorkoutSession, after: TimeInterval) {
		endingSession?.end()
		
		endingSession = session
		DispatchQueue.main.async(after: after) {
			self.endingSession?.end()
			self.endingSession = nil
		}
	}
	
	func clearEndingSessions() {
		endingSession?.end()
		endingSession = nil
	}

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
