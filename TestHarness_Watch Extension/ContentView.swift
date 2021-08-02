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
		.onChange(of: scenePhase) { phase in
			print("Scene Phase: \(phase)")
			switch phase {
			case .active:
				WKInterfaceDevice.current().play(.success)
				
			case .background:
				WKInterfaceDevice.current().play(.failure)
				
			case .inactive:
				WKInterfaceDevice.current().play(.retry)
				
			default:
				break
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
