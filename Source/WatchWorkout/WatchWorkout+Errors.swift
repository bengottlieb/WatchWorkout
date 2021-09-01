//
//  WatchWorkout+Errors.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	public enum WorkoutError: String, LocalizedError {
		case otherWorkoutInProgress
		case workoutAlreadyStarted
		case workoutAlreadyEnded
		case failedToCreateSession
		case failedToCreateBuilder
		case sessionFailedToStart
		case noBuilderAvailable
		case failedToAddSamples
		case failedToFetchTypes
		case notRunning
		case unableToDelete
		case unableToDeleteDueToMissingWorkout
		case noSessionWhenRestoringWorkout
		case noSessionWhenEndingWorkout
		case workoutWasNotActive
	
		public var errorDescription: String? { rawValue }
	}
	
}
#endif
