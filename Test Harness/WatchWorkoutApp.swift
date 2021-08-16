//
//  WatchWorkoutApp.swift
//  WatchWorkout
//
//  Created by Ben Gottlieb on 7/31/21.
//

import SwiftUI
import Portal

@main
struct WatchWorkoutApp: App {
	init() {
		PortalToWatch.setup(messageHandler: MessageHandler.instance)
		DevicePortal.instance.connect()
	//	DevicePortal.instance.startPinging()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
