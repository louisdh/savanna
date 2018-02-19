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
		consoleTextView.string = consoleTextView.string + "\n\(message)"
	}
	
	@nonobjc func log(_ error: Error) {
		
	}
	
	@nonobjc func log(_ token: Cub.Token) {
		
	}

}

class ViewController: NSViewController {
	

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
		
		let runner = Cub.Runner(logDebug: true, logTime: false)
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

	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}


extension ViewController: SyntaxTextViewDelegate {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		document?.text = syntaxTextView.text
		
	}
	
	func lexerForSource(_ source: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: source)
	}
	
}


extension Cub.TokenType: SavannaKit.TokenType {
	
	public var syntaxColorType: SyntaxColorType {
		
		switch self {
		case .booleanAnd, .booleanNot, .booleanOr:
			return .plain
			
		case .shortHandAdd, .shortHandDiv, .shortHandMul, .shortHandPow, .shortHandSub:
			return .plain
			
		case .equals, .notEqual, .dot, .ignoreableToken, .parensOpen, .parensClose, .curlyOpen, .curlyClose, .comma, .squareBracketOpen, .squareBracketClose:
			return .plain
			
		case .comparatorEqual, .comparatorLessThan, .comparatorGreaterThan, .comparatorLessThanEqual, .comparatorGreaterThanEqual:
			return .plain
			
		case .string:
			return .string
		
		case .other:
			return .plain
			
		case .break, .continue, .function, .if, .else, .while, .for, .do, .times, .return, .returns, .repeat, .true, .false, .struct, .guard, .in, .nil:
			return .keyword
			
		case .comment:
			return .comment
			
		case .number:
			return .number
			
		case .identifier:
			return .identifier
			
		}
		
	}
	
}

extension Cub.Token: SavannaKit.Token {
	
	public var savannaTokenType: SavannaKit.TokenType {
		return self.type
	}
	
}

extension Cub.Lexer: SavannaKit.Lexer {
	
	public func lexerForInput(_ input: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: input)
	}
	
	public func getSavannaTokens() -> [SavannaKit.Token] {
		return self.tokenize()
	}
	
}


extension Lioness.TokenType: SavannaKit.TokenType {
	
	public var syntaxColorType: SyntaxColorType {
		
		switch self {
		case .booleanAnd, .booleanNot, .booleanOr:
			return .plain
			
		case .shortHandAdd, .shortHandDiv, .shortHandMul, .shortHandPow, .shortHandSub:
			return .plain
			
		case .equals, .notEqual, .dot, .ignoreableToken, .parensOpen, .parensClose, .curlyOpen, .curlyClose, .comma:
			return .plain
			
		case .comparatorEqual, .comparatorLessThan, .comparatorGreaterThan, .comparatorLessThanEqual, .comparatorGreaterThanEqual:
			return .plain
			
		case .other:
			return .plain
			
		case .break, .continue, .function, .if, .else, .while, .for, .do, .times, .return, .returns, .repeat, .true, .false, .struct:
			return .keyword
			
		case .comment:
			return .comment
			
		case .number:
			return .number
			
		case .identifier:
			return .identifier
			
		}
		
	}
	
}

extension Lioness.Token: SavannaKit.Token {
	
	public var savannaTokenType: SavannaKit.TokenType {
		return self.type
	}
	
}

extension Lioness.Lexer: SavannaKit.Lexer {
	
	public func lexerForInput(_ input: String) -> SavannaKit.Lexer {
		return Lioness.Lexer(input: input)
	}
	
	public func getSavannaTokens() -> [SavannaKit.Token] {
		return self.tokenize()
	}
	
}
