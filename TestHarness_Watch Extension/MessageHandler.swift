//
//  MessageHandler.swift
//  WatchWorkout
//
//  Created by Ben Gottlieb on 8/15/21.
//

import Foundation
import Portal

class MessageHandler: PortalMessageHandler {
	static let instance = MessageHandler()
	
	func didReceive(message: PortalMessage) -> [String : Any]? {
		return nil
	}
	
	func didReceive(file: URL, fileType: PortalFileKind?, metadata: [String : Any]?, completion: @escaping () -> Void) {
		completion()
	}
	
	func didReceive(userInfo: [String : Any]) {
		
	}
	
	
}
