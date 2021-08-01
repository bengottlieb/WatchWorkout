//
//  WatchWorkoutManager.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

public class WatchWorkoutManager: ObservableObject {
	public static let instance = WatchWorkoutManager()

	public var currentWorkout: WatchWorkout? { willSet { objectWillChange.send() }}

}
