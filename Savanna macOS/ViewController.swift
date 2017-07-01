//
//  ViewController.swift
//  Savanna macOS
//
//  Created by Louis D'hauwe on 06/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness
import SavannaKit

extension ViewController: RunnerDelegate {
	
	@nonobjc func log(_ message: String) {
		consoleTextView.string = (consoleTextView.string ?? "") + "\n\(message)"
	}
	
	@nonobjc func log(_ error: Error) {
		
	}
	
	@nonobjc func log(_ token: Token) {
		
	}

}

class ViewController: NSViewController, SyntaxTextViewDelegate {

	@IBOutlet var textView: SyntaxTextView!
	
	@IBOutlet var consoleTextView: NSTextView!
	
	
	
	var document: Document? {
		return view.window?.windowController?.document as? Document
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		textView.tintColor = .white
		textView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(run), name: .run, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(showAST(_ :)), name: .showAST, object: nil)

	}
	
	var currentASTPopover: NSPopover?
	
	func showAST(_ notification: Notification) {
		
		currentASTPopover?.performClose(nil)
		currentASTPopover = nil
		
		let info = notification.userInfo!
		
		let button = info["sender"]! as! NSButton

		let lexer = Lexer(input: textView.text)
		let tokens = lexer.tokenize()
		
		let parser = Parser(tokens: tokens)
		if let nodes = try? parser.parse() {
			
			let body = BodyNode(nodes: nodes)
			let astVisualizer = ASTVisualizer(body: body)
			let image = astVisualizer.draw()
			
			let popover = NSPopover()
			
			let storyboard = NSStoryboard(name: "Main", bundle: nil)
			let viewController = storyboard.instantiateController(withIdentifier: "ASTImageViewController") as! ASTImageViewController
			
			popover.contentViewController = viewController
			
			let window = NSApplication.shared().keyWindow!
			
			
//			let rect = button.convert(button.bounds, to: self.view)

			let rect = button.bounds

			popover.show(relativeTo: rect, of: button, preferredEdge: .minY)
		
			viewController.imageView.image = image
			viewController.imageView.imageScaling = .scaleProportionallyUpOrDown
			
			currentASTPopover = popover
			
		}

		
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
		
		textView.text = document?.text ?? ""

	}

	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		document?.text = syntaxTextView.text

	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

