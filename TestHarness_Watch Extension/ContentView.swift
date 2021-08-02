//
//  ContentView.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var manager = WatchWorkoutManager.instance
	
	var body: some View {
		VStack() {
			HeartRateLabel()
			if let current = manager.currentWorkout {
				WorkoutDetailsView(workout: current)
				if current.phase.hasEnded {
					createWorkoutButton
				}
			} else {
				createWorkoutButton
			}
		}
	}
	
	var createWorkoutButton: some View {
		Button("Create Workout") {
			manager.currentWorkout = WatchWorkout(activity: .cricket)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
