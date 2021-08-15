//
//  WatchWorkout+String.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 8/15/21.
//

import HealthKit
import Suite

extension WatchWorkout {
	public override var description: String {
		var string = "Workout [\(phase)]"
		
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
		
		return string
	}
}
