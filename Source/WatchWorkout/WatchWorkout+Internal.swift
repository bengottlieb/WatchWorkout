//
//  WatchWorkout+Internal.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

extension WatchWorkout {
	func completeWorkout(at date: Date) {
		guard let builder = self.builder, phase == .ending else {
			self.cleanup()
			return
		}
		
		builder.endCollection(withEnd: date) { success, collectionError in
			DispatchQueue.main.async {
				self.phase = .finishing
				if let err = collectionError { self.errors.append(err) }
				
				builder.finishWorkout { workout, finishingError in
					self.workout = workout
					
					DispatchQueue.main.async {
						if let err = finishingError { self.errors.append(err) }

						self.cleanup()
					}
				}
			}
		}
	}
	
	func cleanup() {
		phase = .idle
		if WatchWorkoutManager.instance.currentWorkout == self {
			WatchWorkoutManager.instance.currentWorkout = nil
		}
	}
}
