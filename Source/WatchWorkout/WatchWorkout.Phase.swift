//
//  WatchWorkout.Phase.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

extension WatchWorkout {
	public enum Phase: Equatable { case idle, loading, active, failed(Error)
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
			default: return false
			}
		}
	}
}

