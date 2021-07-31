//
//  WatchWorkout.Phase.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

extension WatchWorkout {
	public enum Phase: Equatable { case idle, loading, active, ending, finishing, failed(Error)
		var isIdle: Bool {
			switch self {
			case .idle, .failed: return true
			default: return false
			}
		}
		
		public static func ==(lhs: Phase, rhs: Phase) -> Bool {
			switch (lhs, rhs) {
			case (.idle, .idle): return true
			case (.loading, .loading): return true
			case (.active, .active): return true
			case (.ending, .ending): return true
			case (.finishing, .finishing): return true
			default: return false
			}
		}
		
		public var title: String {
			switch self {
			case .idle: return "idle"
			case .loading: return "loading"
			case .active: return "active"
			case .ending: return "ending"
			case .finishing: return "finishing"
			case .failed(let err): return "Failed: \(err)"
			}
		}
	}
}

