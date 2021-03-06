//
//  WatchWorkout.Phase.swift
//
//  Created by Ben Gottlieb on 7/31/21.
//

import Foundation

#if os(watchOS)
@available(iOS 13.0, watchOS 7.0, *)
extension WatchWorkout {
	public enum Phase: Equatable { case idle, loading, active, ending, finishing, ended, deleted, failed(Error)
		var isIdle: Bool {
			switch self {
			case .idle, .failed: return true
			default: return false
			}
		}
		
		public var isRunning: Bool {
			switch self {
			case .active, .loading: return true
			default: return false
			}
		}
		
		public var isEnding: Bool {
			switch self {
			case .ending, .finishing, .failed, .ended, .deleted: return true
			default: return false
			}
		}

		public var hasEnded: Bool {
			switch self {
			case .failed, .ended, .deleted: return true
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
			case (.ended, .ended): return true
			case (.deleted, .deleted): return true
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
			case .ended: return "ended"
			case .deleted: return "deleted"
			case .failed(let err): return "Failed: \(err.localizedDescription)"
			}
		}
	}
}
#endif
