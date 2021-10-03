//
//  WatchWorkout+Internal.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit
import Suite

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	func completeWorkout(at date: Date) {
		enqueue("complete") {
			guard let builder = self.builder, self.phase == .ending else {
				print("No builder, or incorrect phase (\(self.phase))")
				self.cleanup()
				self.handlePending()
				return
			}

			builder.endCollection(withEnd: date) { success, collectionError in
				print("Builder ended collection, \(success)")
				DispatchQueue.main.async {
					self.phase = .finishing
					if let err = collectionError { self.errors.append(err) }
					
					builder.finishWorkout { workout, finishingError in
						print("Builder finished workout")
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
		print("Cleaning up")
		phase = .idle
		if isDeleted {
			self.deleteFromHealthKit(completion: didFinishDeletingCompletion)
		} else {
			print("Workout is complete")
			self.phase = .ended
		}
	}
	
	func findWorkout(completion: @escaping (Result<HKWorkout, Error>) -> Void) {
	//	if let current = workout { return current }
		
		if let uuid = workoutID {
			let predicate = HKQuery.predicateForObject(with: uuid)
			let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 1, sortDescriptors: nil) { query, results, error in
				logg("Results from workout query: \(String(describing: results)), error: \(String(describing: error))")
				if let workout = results?.first as? HKWorkout {
					completion(.success(workout))
				} else if let error = error {
					completion(.failure(error))
				} else {
					completion(.failure(WorkoutError.unableToDeleteDueToMissingWorkout))
				}
			}
			healthStore.execute(query)
		} else {
			print("Unable to fetch workout \(String(describing: workoutID))")
			completion(.failure(WorkoutError.unableToDeleteDueToMissingWorkout))
		}
		
	}
	
	func deleteFromHealthKit(completion: ErrorCallback?) {
		findWorkout() { result in
			switch result {
			case .success(let workout):
				print("Workout found, deleting")
				self.deleteAssociatedSamples(for: workout)
				self.healthStore.delete([workout]) { success, deleteError in
					DispatchQueue.main.async {
						if success {
							self.phase = .deleted
						} else {
							self.phase = .failed(deleteError ?? WorkoutError.unableToDelete)
						}
						completion?(deleteError)
					}
				}
				
			case .failure(let error):
				print("Failed to locate workout: \(error)")
				self.phase = .deleted
				completion?(error)
			}
		}
		didFinishDeletingCompletion = nil
	}
	
	func deleteAssociatedSamples(for workout: HKWorkout) {
		let sampleTypes: [HKQuantityType] = [.heartRateType, .basalCalorieType, .activeCalorieType]
		let predicate = HKQuery.predicateForObjects(from: workout)
		sampleTypes.forEach { type in
			healthStore.deleteObjects(of: type, predicate: predicate) { success, count, error in
				print("deleted \(count) \(type) objects")
				logg(error: error, "Problem deleting \(count) objects of type: \(type)")
			}
		}
	}
}
#endif
