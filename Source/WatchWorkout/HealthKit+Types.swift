//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/2/21.
//

import HealthKit

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
public extension HKQuantityType {
	static let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
	static let activeCalorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
	static let basalCalorieType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
	static let appleExerciseTime = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
	static let appleStandTime = HKQuantityType.quantityType(forIdentifier: .appleStandTime)!

	static let workoutType = HKObjectType.workoutType()
}

@available(iOS 13.0, watchOS 7.0, *)
public extension HKUnit {
	static let calorieUnit = HKUnit.kilocalorie()
	static let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
}

#endif
