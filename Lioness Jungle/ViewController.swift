//
//  ViewController.swift
//  Lioness Jungle
//
//  Created by Louis D'hauwe on 06/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness
import JungleKit

extension ViewController: RunnerDelegate {
	
	@nonobjc func log(_ message: String) {
		consoleTextView.string = (consoleTextView.string ?? "") + "\n\(message)"
	}
	
	@nonobjc func log(_ error: Error) {
		
	}
	
	@nonobjc func log(_ token: Token) {
		
	}

}

class ViewController: NSViewController, NSTextViewDelegate {

	@IBOutlet var textView: SyntaxTextView!
	
	@IBOutlet var consoleTextView: NSTextView!
	
	
	
	var document: Document? {
		return view.window?.windowController?.document as? Document
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		textView.tintColor = .white
//		textView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(run), name: .run, object: nil)
		
	}
	
	func run() {
		
		let runner = Runner(logDebug: true, logTime: false)
		runner.delegate = self
		
		try? runner.run(textView.text)
		
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
//		contentVi
//		[theWindow setContentView:scrollview];
//		[theWindow makeKeyAndOrderFront:nil];
//		[theWindow makeFirstResponder:theTextView];
//
//		
//		textView.scrollView
		
//		textView.string = document?.text

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

