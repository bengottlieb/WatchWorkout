//
//  WatchWorkout.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Suite
import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
public class WatchWorkout: NSObject, ObservableObject {
	@Published public internal(set) var phase = Phase.idle { didSet {
		if WatchWorkoutManager.instance.loggingEnabled { logg("Current WatchWorkout Phase: \(phase)") }
	}}
	
	let id = UUID()
	@Published public var startedAt: Date?
	@Published public var endedAt: Date?
	@Published public var errors: [Error] = []
	public internal(set) var isDeleted = false
	public var hasStarted: Bool { startedAt != nil }
	public var identifier: String?
	
	public var workout: HKWorkout? { didSet { workoutID = workout?.uuid }}
	public var workoutID: UUID?
	public let basalEnergy = TrackedCalories()
	public let activeEnergy = TrackedCalories()
	public private(set) var wasRestored = false


	var heartRateQuery: HKQuery?
	let healthStore = HKHealthStore()
	var builder: HKLiveWorkoutBuilder?
	var session: HKWorkoutSession?
	var pending: [Pending] = []
	var isProcessing = false
	var processingLabel = ""
	
	struct Pending {
		let block: (() -> Void)?
		let label: String
		
		init(_ label: String, _ block: (() -> Void)?) {
			self.label = label
			self.block = block
		}
	}
	
	var didFinishDeletingCompletion: ErrorCallback?

	var configuration: HKWorkoutConfiguration
	
	deinit {
		if phase.isRunning, !phase.hasEnded {
			print("### WARNING: deallocating an active workout: \(self)")
		}
	}

	public override var description: String { asText }
	public init(activity: HKWorkoutActivityType, location: HKWorkoutSessionLocationType = .indoor) {
		configuration = HKWorkoutConfiguration(activity: activity, location: location)
		super.init()
	}
	
	public init(configuration config: HKWorkoutConfiguration?) {
		configuration = config ?? .defaultConfiguration
		super.init()
	}
	
	init(session restoredSession: HKWorkoutSession) {
		configuration = restoredSession.workoutConfiguration
		wasRestored = true
		super.init()
		
		session = restoredSession
	}

	func restore(completion: @escaping ErrorCallback) {
		if phase.hasEnded {
			completion(WorkoutError.workoutAlreadyEnded)
			return
		}
		start(at: session?.startDate ?? Date(), completion: completion)
	}
	
	func enqueue(_ label: String, _ block: @escaping () -> Void) {
		DispatchQueue.main.async {
			print("queuing \(label), processing: \(self.processingLabel)")
			self.pending.append(Pending(label, block))
			WatchWorkoutManager.instance.holdOnTo(self)
			if !self.isProcessing { self.handlePending() }
		}
	}
	
	func handlePending() {
		DispatchQueue.main.async {
			self.isProcessing = false
			guard let next = self.pending.first else {
				WatchWorkoutManager.instance.finished(with: self)
				return
			}
			logg("Handling \(next.label)")
			self.processingLabel = next.label
			self.pending.removeFirst()
			self.isProcessing = true
			next.block?()
		}
	}
	
	public func end(at date: Date = Date(), gracePeriod: TimeInterval = 3, completion: ErrorCallback? = nil) {
		print("Starting to finish the workout")
		enqueue("end") {
//			print("------------- Active -------------")
//			print(self.activeEnergy)
//			print("------------- Basal -------------")
//			print(self.basalEnergy)
			guard self.phase != .ended, self.phase != .ending, self.session?.state != .ended else {
				self.handlePending()
				completion?(nil)
				return
			}
			
			guard self.phase == .active else {
				self.phase = .idle
				self.handlePending()
				completion?(WatchWorkout.WorkoutError.workoutWasNotActive)
				return
			}

			guard let session = self.session else {
				self.phase = self.phase == .active ? .idle : self.phase
				self.handlePending()
				completion?(WatchWorkout.WorkoutError.noSessionWhenEndingWorkout)
				return
			}

			if WatchWorkoutManager.instance.loggingEnabled { logg("Ending workout, current state: \(session.state)") }
			self.phase = .ending
			self.endedAt = date
			session.stopActivity(with: date)
			WatchWorkoutManager.instance.end(session, after: gracePeriod)
			self.handlePending()
			completion?(nil)
		}
	}

	public func delete(completion: @escaping ErrorCallback) {
		enqueue("delete") {
			if self.isDeleted {
				completion(nil)
				self.handlePending()
				return
			}
			
			if self.phase == .ended {
				print("already ended, calling delete now")
				self.deleteFromHealthKit(completion: completion)
				self.handlePending()
				return
			}

			guard self.phase.isRunning else {
				print("Not running, calling delete now")
				self.deleteFromHealthKit(completion: completion)
				self.handlePending()
				return
			}
			
			self.didFinishDeletingCompletion = completion
			self.isDeleted = true
			self.end()
			self.handlePending()
		}
	}
	
	public var isRunning: Bool {
		phase == .active || phase == .loading
	}
}

@available(iOS 13.0, watchOS 7.0, *)
public extension WatchWorkout {
	static var sample = WatchWorkout(activity: .rugby)
}
#endif
