//
//  ContentView.swift
//  WatchWorkout
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI
import HealthKit
import Portal

struct ContentView: View {
	
	public let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
	var body: some View {
		ZStack() {
			Button("Authorize Healthkit") {
				HKHealthStore().requestAuthorization(toShare: [HKObjectType.workoutType()], read: [HKObjectType.workoutType(), heartRateType, HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!]) { success, error in
					if let err = error {
						print("Error when authorizing HealthKit: \(err)")
					}
				}
			}
			
			FullScreenConnectionIndicator()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
