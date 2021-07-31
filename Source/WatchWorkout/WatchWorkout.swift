//
//  WatchWorkout.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Suite
import HealthKit

public class WatchWorkout: NSObject, ObservableObject {
	@Published public internal(set) var phase = Phase.idle
	@Published public var startedAt: Date?
	@Published public var endedAt: Date?
	@Published public var errors: [Error] = []

	public var workout: HKWorkout?

	let healthStore = HKHealthStore()
	var builder: HKLiveWorkoutBuilder?
	var session: HKWorkoutSession?

	var configuration: HKWorkoutConfiguration
	
	public init(activity: HKWorkoutActivityType, location: HKWorkoutSessionLocationType = .outdoor) {
		configuration = HKWorkoutConfiguration(activity: activity, location: location)
		super.init()
	}
	
	public init(configuration config: HKWorkoutConfiguration?) {
		configuration = config ?? .defaultConfiguration
		super.init()
	}
	
	public func start(at date: Date = Date(), completion: @escaping (Error?) -> Void) {
		if WatchWorkoutManager.instance.currentWorkout != nil, WatchWorkoutManager.instance.currentWorkout != self {
			completion(WorkoutError.otherWorkoutInProgress)
			return
		}
		
		if !phase.isIdle {
			completion(WorkoutError.workoutAlreadyStarted)
			return
		}

		do {
			phase = .loading
			session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
			builder = session?.associatedWorkoutBuilder()
			session?.delegate = self

			builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
			builder?.delegate = self
			if builder == nil {
				completion(WorkoutError.failedToCreateBuilder)
				phase = .failed(WorkoutError.failedToCreateBuilder)
			}
			builder?.beginCollection(withStart: date) { started, error in
				DispatchQueue.main.async {
					if started {
						self.phase = .active
						self.session?.startActivity(with: date)
					}
					if let err = error {
						self.phase = .failed(err)
					} else {
						self.startedAt = date
						self.phase = .active
					}
					completion(error)
				}
			}
		} catch {
			completion(error)
		}
	}
	
	public func end(at date: Date = Date()) {
		guard phase == .active, let session = self.session else {
			phase = phase == .active ? .idle : phase
			return
		}
		
		phase = .ending
		endedAt = date
		session.stopActivity(with: date)
		session.end()
	}
}

public extension WatchWorkout {
	static var sample = WatchWorkout(activity: .rugby)
}
