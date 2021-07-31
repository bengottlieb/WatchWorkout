//
//  WatchWorkout+Delegates.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite


extension WatchWorkout: HKLiveWorkoutBuilderDelegate {
	public func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
		
	}
	
	public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
		
	}
	
	
}

extension WatchWorkout: HKWorkoutSessionDelegate {
	public func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		logg("Workout transitioned from \(fromState.name) to \(toState.name)")
		if toState == .ended {
			completeWorkout(at: date)
		}
	}

	public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		logg(error: error, "Workout session failed")
	}
}


