//
//  HealthKit+Extensions.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit

extension HKWorkoutConfiguration {
	public static var defaultConfiguration = HKWorkoutConfiguration(activity: .other, location: .outdoor)
	
	convenience init(activity: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
		self.init()
		
		self.activityType = activity
		self.locationType = location
	}
}

extension HKWorkoutSessionState {
	var name: String {
		switch self {
		case .notStarted: return "not started"
		case .running: return "running"
		case .ended: return "ended"
		case .paused: return "paused"
		case .prepared: return "prepared"
		case .stopped: return "stopped"
		@unknown default: return "unknown"
		}
	}
}
