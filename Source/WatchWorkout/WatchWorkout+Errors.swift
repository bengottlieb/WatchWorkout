//
//  WatchWorkout+Errors.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

extension WatchWorkout {
	public enum WorkoutError: String, LocalizedError {
		case workoutAlreadyStarted
		case failedToCreateBuilder
	}
}
