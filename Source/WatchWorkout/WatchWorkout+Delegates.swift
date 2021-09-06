//
//  WatchWorkout+Delegates.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout: HKLiveWorkoutBuilderDelegate {
	public func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
		if let heartRateStats = workoutBuilder.statistics(for: HKQuantityType.heartRateType) {
			if let value = heartRateStats.mostRecentQuantity()?.doubleValue(for: HKUnit.heartRateUnit) {
				HeartRateMonitor.instance.set(heartRate: value)
			}
		}
		
//		if WatchWorkoutManager.instance.trackCalories {
			if let activeEnergyStats = workoutBuilder.statistics(for: HKQuantityType.activeCalorieType) { activeEnergy.track(statistics: activeEnergyStats) }
			if let basalEnergyStats = workoutBuilder.statistics(for: HKQuantityType.basalCalorieType) { basalEnergy.track(statistics: basalEnergyStats) }
//		}
	}
	
	public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
		print("collected event")
	}
	
	
}

@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout: HKWorkoutSessionDelegate {
	public func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		logg("Workout transitioned from \(fromState) to \(toState)")
		if toState == .ended {
			completeWorkout(at: date)
		}
	}

	public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		logg(error: error, "Workout session failed")
	}
}
#endif
