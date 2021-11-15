//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 11/15/21.
//

import SwiftUI

@available(iOS 13.0, watchOS 7.0, *)
public struct WorkoutIndicatorView: View {
	@ObservedObject var workouts = WatchWorkoutManager.instance
	
	public init() { }
	public var body: some View {
		VStack() {
			Spacer()
			HStack() {
				content
				Spacer()
			}
		}
	}
	
	
	@ViewBuilder var content: some View {
		if let active = workouts.currentWorkout {
			WorkoutIndicator(workout: active)
		} else {
			Image(systemName: "figure.stand")
				.foregroundColor(.gray)
		}
	}
	
	struct WorkoutIndicator: View {
		@ObservedObject var workout: WatchWorkout
		
		func color(for workout: WatchWorkout) -> Color {
			switch workout.phase {
			
			case .idle: return .gray
			case .loading: return .yellow
			case .active: return .green
			case .ending: return .orange
			case .finishing: return .blue
			case .ended: return .red
			case .deleted: return .pink
			case .failed: return .purple
			}
		}

		var body: some View {
			VStack() {
				Image(systemName: "figure.walk")
			
				if workout.isPaused { Image(systemName: "pause.circle")}
			}
			.foregroundColor(color(for: workout))
		}
	}
}

@available(iOS 13.0, watchOS 7.0, *)
struct WorkoutIndicatorView_Previews: PreviewProvider {
	static var previews: some View {
		WorkoutIndicatorView()
	}
}
