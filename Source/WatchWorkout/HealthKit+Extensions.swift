//
//  HealthKit+Extensions.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import HealthKit

#if os(watchOS)
extension HKWorkoutConfiguration {
	public static var defaultConfiguration = HKWorkoutConfiguration(activity: .other, location: .outdoor)
	
	convenience init(activity: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
		self.init()
		
		self.activityType = activity
		self.locationType = location
	}
}

extension HKWorkoutSessionState: CustomStringConvertible {
	public var description: String {
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
#endif
