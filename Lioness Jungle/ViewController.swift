//
//  ViewController.swift
//  Lioness Jungle
//
//  Created by Louis D'hauwe on 06/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {

	@IBOutlet var textView: NSTextView!
	
	var document: Document? {
		return view.window?.windowController?.document as? Document
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		textView.delegate = self
		
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		textView.string = document?.text

	}

	func textDidChange(_ notification: Notification) {
		guard let textView = notification.object as? NSTextView else {
			return
		}

		document?.text = textView.textStorage?.string ?? ""

	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

