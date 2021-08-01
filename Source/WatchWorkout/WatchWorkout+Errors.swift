//
//  WatchWorkout+Errors.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

extension WatchWorkout {
	public enum WorkoutError: String, LocalizedError {
		case otherWorkoutInProgress
		case workoutAlreadyStarted
		case failedToCreateBuilder
		case noBuilderAvailable
		case failedToAddSamples
		case failedToFetchTypes
		case notRunning
		case unableToDelete
		case unableToDeleteDueToMissingWorkout
	}
}
