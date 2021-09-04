//
//  WatchWorkout+Start.swift
//  
//
//  Created by Ben Gottlieb on 9/2/21.
//

import Suite
import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	public func start(at date: Date = Date(), completion: @escaping ErrorCallback) {
		enqueue("permissionCheck") {
			WatchWorkoutManager.instance.authorizeHealthKit { error in
				if let err = error {
					completion(err)
				} else {
					self.run(at: date, completion: completion)
				}
				self.handlePending()
			}
		}
	}
	
	func run(at date: Date = Date(), completion: @escaping ErrorCallback) {
		enqueue("start") {
			if self.phase.hasEnded {
				completion(WorkoutError.workoutAlreadyEnded)
				return
			}
			self.startedAt = date
			if WatchWorkoutManager.instance.currentWorkout?.phase.isRunning == true {
				completion(WorkoutError.otherWorkoutInProgress)
				self.handlePending()
				return
			}
			
			if !self.phase.isIdle {
				completion(WorkoutError.workoutAlreadyStarted)
				self.handlePending()
				return
			}

			do {
				self.phase = .loading
				if self.session == nil {
					WatchWorkoutManager.instance.clearEndingSessions()
					self.session = try HKWorkoutSession(healthStore: self.healthStore, configuration: self.configuration)
				}
				guard let session = self.session else {
					completion(WorkoutError.failedToCreateSession)
					self.phase = .failed(WorkoutError.failedToCreateSession)
					self.handlePending()
					return
				}
				self.builder = session.associatedWorkoutBuilder()
				if self.builder == nil {
					completion(WorkoutError.failedToCreateBuilder)
					self.phase = .failed(WorkoutError.failedToCreateBuilder)
					self.handlePending()
					return
				}
				session.delegate = self

				self.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore, workoutConfiguration: self.configuration)
				self.builder?.delegate = self
				if WatchWorkoutManager.instance.loggingEnabled { logg("builder: beginCollection: \(String(describing: self.builder))") }
				self.builder?.beginCollection(withStart: date) { started, error in
					if WatchWorkoutManager.instance.loggingEnabled { logg("builder: completed beginCollection") }
					if let err = error, WatchWorkoutManager.instance.loggingEnabled { print("### Error when beginning collection: \(err), \(err.localizedDescription)") }
					DispatchQueue.main.async {
						if WatchWorkoutManager.instance.loggingEnabled { logg("Started workout, curent state: \(session.state)") }
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
						self.handlePending()
					}
				}
			} catch {
				completion(error)
				self.handlePending()
			}
		}
	}
}
#endif
