//
//  WatchWorkoutManagerOld.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
public class WatchWorkoutManager: ObservableObject {
	public static let instance = WatchWorkoutManager()

	@Published public private(set) var currentWorkout: WatchWorkout?
	public internal(set) var hasHealthKitReadAccess = false
	public internal(set) var hasHealthKitWriteAccess = false
	public var store = HKHealthStore()
	public var loggingEnabled = false
	public var trackHeartRate = true

	private var endingSession: HKWorkoutSession?
	private var inProgressWorkouts: [WatchWorkout] = []
	private let inProgressQueue = DispatchQueue(label: "inProgressWatchWorkouts")
	
	public var typesToRead: Set = [HKQuantityType.heartRateType, HKQuantityType.workoutType]
	public var typesToWrite: Set = [HKQuantityType.workoutType]

	init() {
		checkForHealtkitAccess()
		checkForHeartRateAccess()
	}

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

	public func load(workout: WatchWorkout) {
		currentWorkout = workout
		if loggingEnabled { print("### Watch Workout set to \(workout.description)") }
	}

	public func clearCurrent() {
		if loggingEnabled { print("### Clearing current workout") }
		if currentWorkout == nil { return }
		currentWorkout?.end()
		currentWorkout = nil
	}

	func end(_ session: HKWorkoutSession, after: TimeInterval) {
		if loggingEnabled { print("### Ending current workout session") }

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
