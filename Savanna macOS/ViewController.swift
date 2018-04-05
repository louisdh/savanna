//
//  ViewController.swift
//  Savanna macOS
//
//  Created by Louis D'hauwe on 06/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness
import Cub
import SavannaKit

extension ViewController: Cub.RunnerDelegate {
	
	@nonobjc func log(_ message: String) {
//		consoleTextView.string = consoleTextView.string + "\n\(message)"
	}
	
	@nonobjc func log(_ error: Error) {
		
	}
	
	@nonobjc func log(_ token: Cub.Token) {
		
	}

}

enum SavannaDocument {
	case cub(CubDocument)
	case prideland(PridelandDocument)
	
	var text: String {
		switch self {
		case .cub(let cubDoc):
			return cubDoc.text
			
		case .prideland(let pridelandDoc):
			return pridelandDoc.text
		}
	}
	
}

class ViewController: NSViewController {
	

	@IBOutlet var textView: SyntaxTextView!
	
	@IBOutlet var consoleTextView: NSTextView!
	
	var progressToolbarItem: ProgressToolbarItem! {
		
		let windowController = self.view.window?.windowController as! MainWindowController
		
		return windowController.progressToolbarItem
	}

	var document: SavannaDocument? {
		
		let doc = view.window?.windowController?.document
		
		if let cubDoc = doc as? CubDocument {
			return .cub(cubDoc)
		}
		
		if let pridelandDoc = doc as? PridelandDocument {
			return .prideland(pridelandDoc)
		}
		
		return nil
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		textView.tintColor = .white
		textView.delegate = self
		
//		textView.textView.becomeFirstResponder()
		
		NotificationCenter.default.addObserver(self, selector: #selector(run), name: .run, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(showAST(_ :)), name: .showAST, object: nil)

		self.consoleTextView.string = ""

	}
	
	var currentASTPopover: NSPopover?
	
	@objc func showAST(_ notification: Notification) {
		/*
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
			
			let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
			let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ASTImageViewController")) as! ASTImageViewController
			
			popover.contentViewController = viewController
			
			let window = NSApplication.shared.keyWindow!
			
			
//			let rect = button.convert(button.bounds, to: self.view)

			let rect = button.bounds

			popover.show(relativeTo: rect, of: button, preferredEdge: .minY)
		
			viewController.imageView.image = image
			viewController.imageView.imageScaling = .scaleProportionallyUpOrDown
			
			currentASTPopover = popover
			
		}
*/
		
	}

	@objc func run() {
		
		progressToolbarItem.text = "Compiling ..."
		
		self.consoleTextView.string = ""
		self.consoleTextView.font = NSFont(name: "Menlo", size: 15.0)
		self.consoleTextView.textColor = .white
		
		let runner = Cub.Runner(logDebug: false, logTime: false)
		runner.delegate = self
		
		runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: true) { (args, completionHandler) in
			
			guard let input = args["input"] else {
				_ = completionHandler(.string(""))
				return
			}
			
			let parameter = input.description(with: runner.compiler)
			
			DispatchQueue.main.async {
				self.consoleTextView.string = self.consoleTextView.string + "\(parameter)\n"
			}
			

			_ = completionHandler(.string(""))
		}
		
		let code = self.textView.text
		
		DispatchQueue.global(qos: .background).async {
			
			do {
				try runner.run(code)
				
				DispatchQueue.main.async {
					self.progressToolbarItem.text = "Finished running"
				}
				
			} catch {
				print(error)
				DispatchQueue.main.async {
					self.consoleTextView.string = self.consoleTextView.string + "\n\(error)"
				}
				
			}
			
		}

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

//		textView.textView.becomeFirstResponder()
		
	}

	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}


extension ViewController: SyntaxTextViewDelegate {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		
		guard let document = document else {
			return
		}
		
		switch document {
		case .cub(let cubDoc):
			cubDoc.text = syntaxTextView.text
			
		case .prideland(let pridelandDoc):
			pridelandDoc.text = syntaxTextView.text
		}
		
	}
	
	func lexerForSource(_ source: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: source)
	}
	
}
