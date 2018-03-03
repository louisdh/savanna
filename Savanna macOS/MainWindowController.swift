//
//  MainWindowController.swift
//  Savanna macOS
//
//  Created by Louis D'hauwe on 25/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import AppKit

class MainWindowController: NSWindowController {
	
	@IBOutlet weak var toolbar: NSToolbar!
	
	@IBOutlet weak var progressToolbarItem: ProgressToolbarItem!
	
	
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
	
	@IBAction func showAST(_ sender: NSButton) {
		
		NotificationCenter.default.post(name: .showAST, object: nil, userInfo: ["sender": sender])
	}
	
}
