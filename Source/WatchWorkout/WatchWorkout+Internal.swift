//
//  WatchWorkout+Internal.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

#if os(watchOS)
extension WatchWorkout {
	func completeWorkout(at date: Date) {
		enqueue("complete") {
			guard let builder = self.builder, self.phase == .ending else {
				self.cleanup()
				self.handlePending()
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
							self.handlePending()
						}
					}
				}
			}
		}
	}
	
	func cleanup() {
		phase = .idle
		if isDeleted {
			self.deleteFromHealthKit(completion: didFinishDeletingCompletion)
		} else {
			self.phase = .ended
		}
	}
	
	func deleteFromHealthKit(completion: ErrorCallback?) {
		if let workout = self.workout {
			healthStore.delete([workout]) { success, deleteError in
				DispatchQueue.main.async {
					if success {
						self.phase = .deleted
					} else {
						self.phase = .failed(deleteError ?? WorkoutError.unableToDelete)
					}
					completion?(deleteError)
				}
			}
		} else {
			self.phase = .deleted
			completion?(WorkoutError.unableToDeleteDueToMissingWorkout)
		}
		
		didFinishDeletingCompletion = nil
	}
}
#endif
