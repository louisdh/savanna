//
//  AppDelegate.swift
//  Lioness Jungle
//
//  Created by Louis D'hauwe on 06/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa

extension Notification.Name {
	static let run = Notification.Name("run")
}

class MainWindowController: NSWindowController {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		shouldCascadeWindows = true
	}
	
	override init(window: NSWindow?) {
		super.init(window: window)
		
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
	}

	@IBAction func run(_ sender: NSButton) {
		
		NotificationCenter.default.post(name: .run, object: nil)
		
	}
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

