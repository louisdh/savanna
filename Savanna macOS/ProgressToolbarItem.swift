//
//  ProgressToolbarItem.swift
//  Savanna
//
//  Created by Louis D'hauwe on 16/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Cocoa

class ProgressToolbarItem: NSToolbarItem {

	let textView = NSTextView()

	var text: String = "" {
		didSet {
			textView.string = text
		}
	}
	
	override init(itemIdentifier: NSToolbarItem.Identifier) {
		super.init(itemIdentifier: itemIdentifier)
		sharedInit()
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		sharedInit()
	}
	
	func sharedInit() {
		let wrapperView = NSView()
		
		wrapperView.wantsLayer = true
		wrapperView.updateLayer()
		
		self.view = wrapperView
		
		guard let layer = wrapperView.layer else {
			return
		}
		
		layer.backgroundColor = NSColor(calibratedWhite: 0.95, alpha: 1.0).cgColor
		layer.borderColor = NSColor.lightGray.withAlphaComponent(0.4).cgColor
		layer.borderWidth = 1.0
		
		layer.cornerRadius = 6.0
		
		minSize = CGSize(width: 320, height: 28)
		maxSize = CGSize(width: 320, height: 28)
	
		
		textView.isEditable = false
		
		wrapperView.addSubview(textView)
		
		textView.isSelectable = false
		textView.frame = wrapperView.bounds
		
		textView.sizeToFit()

		textView.frame.origin.y = (28 - textView.frame.height) / 2.0
		
		textView.backgroundColor = .clear
		
	}
	
}

class AdaptiveSpaceToolbarItem: NSToolbarItem {
	
	override public var label: String {
		get {
			return ""
		}
		set { }
	}
	
	override public var paletteLabel: String {
		get {
			return "Adaptive Space"
		}
		set { }
	}
	
	var adaptiveSpaceItemView: AdaptiveSpaceItemView?
	
	var calculatedMinSize: NSSize {
		guard let items = toolbar?.items else { return super.minSize }
		guard let index = items.index(of: self) else { return super.minSize }
		guard let thisFrame = view?.superview?.frame else { return super.minSize }
		
		if thisFrame.origin.x > 0 {
			var space: CGFloat = 0
			if items.count > index + 1 {
				let nextItem = items[index + 1]
				guard let nextFrame = nextItem.view?.superview?.frame else { return super.minSize }
				guard let toolbarFrame = nextItem.view?.superview?.superview?.frame else { return super.minSize }
				
				space = (toolbarFrame.size.width - nextFrame.size.width) / 2 - thisFrame.origin.x - 3
				if space < 0 { space = 0 }
			}
			
			let size = super.minSize
			return NSSize(width: space, height: size.height)
		}
		
		return super.minSize
	}
	
	var calculatedMaxSize: NSSize {
		let size = super.maxSize
		return NSSize(width: minSize.width, height: size.height)
	}
	
	override init(itemIdentifier: NSToolbarItem.Identifier) {
		super.init(itemIdentifier: itemIdentifier)
		sharedInit()
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		sharedInit()
	}
	
	func sharedInit() {
		adaptiveSpaceItemView = AdaptiveSpaceItemView(frame: NSMakeRect(0,0,1,1))
		adaptiveSpaceItemView?.adaptiveSpaceItem = self
		view = adaptiveSpaceItemView
	}
	
	func updateWidth() {
		minSize = calculatedMinSize
		maxSize = calculatedMaxSize
	}
	
}

class AdaptiveSpaceItemView: NSView {
	
	var adaptiveSpaceItem: AdaptiveSpaceToolbarItem?
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return true
	}
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		NotificationCenter.default.addObserver(self, selector: #selector(windowResized), name: NSWindow.didResizeNotification, object: window)
		adaptiveSpaceItem?.updateWidth()
	}
	
	@objc func windowResized(notification: NSNotification) {
		adaptiveSpaceItem?.updateWidth()
	}
	
}
