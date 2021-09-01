//
//  WatchWorkout+String.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 8/15/21.
//

import HealthKit
import Suite

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	public var asText: String {
		var string = "Workout \(id) [\(phase)]"
		
		if wasRestored { string += " restored" }
		
		if let started = startedAt {
			string += " " + started.hourMinuteString + " -"
		}
		
		if let ended = endedAt {
			string += " " + ended.hourMinuteString
		}
		
		if let state = session?.state {
			string += " state: \(state)"
		}
		
		if !pending.isEmpty {
			string += ", \(pending.map({ $0.label }).joined(separator: ", ")) pending"
		}
		
		return string
	}
}
#endif
