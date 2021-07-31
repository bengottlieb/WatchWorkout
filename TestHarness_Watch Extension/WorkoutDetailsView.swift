//
//  WorkoutDetailsView.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI

struct WorkoutDetailsView: View {
	@ObservedObject var workout: WatchWorkout
	
	var body: some View {
		VStack() {
			Text("Phase: \(workout.phase.title)")
		
			switch workout.phase {
			case .idle:
				Button("Start") { workout.start() { err in
					if let error = err { print("Error starting a workout: \(error)")}
				}}
				
			case .active:
				Button("End") { workout.end() }
				Button("Delete") { workout.delete() { err in
					if let error = err { print("Error deleting a workout: \(error)")}
				}}
				
			case .ended:
				Button("Delete") { workout.delete() { err in
					if let error = err { print("Error deleting a workout: \(error)")}
				}}

			default:
				Text("processing…")
			}
		}
	}
}

struct WorkoutDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		WorkoutDetailsView(workout: .sample)
	}
}
