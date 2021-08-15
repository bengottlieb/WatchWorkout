//
//  ContentView.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var manager = WatchWorkoutManager.instance
	@Environment(\.scenePhase) var scenePhase
	let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
	@State var descriptionText = ""

	var body: some View {
		ScrollView() {
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
				
				Text(descriptionText)
			}
		}
		.onReceive(timer) { _ in
			descriptionText = manager.currentWorkout?.description ?? "--"
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
