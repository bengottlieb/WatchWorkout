//
//  WatchWorkoutManager.swift
//  WatchWorkout
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

public class WatchWorkoutManager: ObservableObject {
	public let instance = WatchWorkoutManager()

	public var currentWorkout: WatchWorkout? { willSet { objectWillChange.send() }}
	public func createWorkout(using workoutConfiguration: HKWorkoutConfiguration) {
		
	}
}
