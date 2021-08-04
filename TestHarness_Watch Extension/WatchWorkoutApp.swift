//
//  WatchWorkoutApp.swift
//  TestHarness_Watch Extension
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI
import WatchKit

@main
struct WatchWorkoutApp: App {
	@WKExtensionDelegateAdaptor(WatchKitAppDelegate.self) var delegate
	@Environment(\.scenePhase) var scenePhase
	
	var body: some Scene {
		WindowGroup {
			NavigationView {
				ContentView()
			}
		}
	}
}

extension ScenePhase: CustomStringConvertible {
	public var description: String {
		switch self {
		case .background: return "background"
		case .inactive: return "inactive"
		case .active: return "active"
		default: return "unknown"
		}
	}
}


class WatchKitAppDelegate: NSObject, WKExtensionDelegate {
	func handleActiveWorkoutRecovery() {
		print("handleActiveWorkoutRecovery")
		WatchWorkoutManager.instance.recoverActiveWorkout()
	}
}
