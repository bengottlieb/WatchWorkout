//
//  WatchWorkout.swift
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
	public internal(set) var isDeleted = false
	public var hasStarted: Bool { startedAt != nil }
	

	public var workout: HKWorkout?

	let healthStore = HKHealthStore()
	var builder: HKLiveWorkoutBuilder?
	var session: HKWorkoutSession?
	
	var didFinishDeletingCompletion: ErrorCallback?

	var configuration: HKWorkoutConfiguration
	
	public init(activity: HKWorkoutActivityType, location: HKWorkoutSessionLocationType = .outdoor) {
		configuration = HKWorkoutConfiguration(activity: activity, location: location)
		super.init()
	}
	
	public init(configuration config: HKWorkoutConfiguration?) {
		configuration = config ?? .defaultConfiguration
		super.init()
	}
	
	init(session restoredSession: HKWorkoutSession) {
		configuration = restoredSession.workoutConfiguration
		super.init()
		
		session = restoredSession
	}

	func restore(completion: @escaping ErrorCallback) {
		start(at: session?.startDate ?? Date(), completion: completion)
	}
	
	public func start(at date: Date = Date(), completion: @escaping ErrorCallback) {
		if WatchWorkoutManager.instance.currentWorkout?.phase.isRunning == true {
			completion(WorkoutError.otherWorkoutInProgress)
			return
		}
		
		if !phase.isIdle {
			completion(WorkoutError.workoutAlreadyStarted)
			return
		}

		do {
			phase = .loading
			if session == nil { session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration) }
			guard let session = session else {
				completion(WorkoutError.failedToCreateSession)
				phase = .failed(WorkoutError.failedToCreateSession)
				return
			}
			builder = session.associatedWorkoutBuilder()
			if builder == nil {
				completion(WorkoutError.failedToCreateBuilder)
				phase = .failed(WorkoutError.failedToCreateBuilder)
			}
			session.delegate = self

			builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
			builder?.delegate = self
			builder?.beginCollection(withStart: date) { started, error in
				DispatchQueue.main.async {
					logg("Started workout, curent state: \(session.state)")
					switch session.state {
					case .stopped, .ended:
						self.phase = .failed(error ?? WorkoutError.sessionFailedToStart)
						completion(error ?? WorkoutError.sessionFailedToStart)
						
					case .running:
						self.phase = .active
						completion(nil)

					case .notStarted, .prepared:
						self.phase = .active
						session.startActivity(with: date)
						completion(nil)

					case .paused:
						self.phase = .active
						session.resume()
						completion(nil)

					default:
						self.phase = .failed(error ?? WorkoutError.sessionFailedToStart)
						completion(error ?? WorkoutError.sessionFailedToStart)
					}
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

	public func delete(completion: @escaping ErrorCallback) {
		if isDeleted {
			completion(nil)
			return
		}
		
		if phase == .ended {
			deleteFromHealthKit(completion: completion)
			return
		}

		guard phase.isRunning else {
			completion(WorkoutError.notRunning)
			return
		}
		
		didFinishDeletingCompletion = completion
		isDeleted = true
		end()
	}
}

public extension WatchWorkout {
	static var sample = WatchWorkout(activity: .rugby)
}
