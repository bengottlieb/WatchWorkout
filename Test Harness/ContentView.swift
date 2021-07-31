//
//  ContentView.swift
//  WatchWorkout
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
		
		Button("Authorize Healthkit") {
			HKHealthStore().requestAuthorization(toShare: [HKObjectType.workoutType()], read: [HKObjectType.workoutType()]) { success, error in
				if let err = error {
					print("Error when authorizing HealthKit: \(err)")
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
