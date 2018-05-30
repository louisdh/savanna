//
//  DocumentViewController.swift
//  Savanna iOS
//
//  Created by Louis D'hauwe on 30/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import UIKit
import SavannaKit
import Lioness
import Cub
import InputAssistant
import PanelKit

func getRunner(consoleDisplayer: ConsoleDisplayer) -> Cub.Runner {
	
	let runner = Cub.Runner(logDebug: false, logTime: false)
	
	let captureShellCommand = """
						The captureShell function can only be used in OpenTerm.
						This function is included in Savanna for testing OpenTerm script, without actually executing any commands.
						- Returns: an empty string
						"""
	
	runner.registerExternalFunction(documentation: captureShellCommand, name: "captureShell", argumentNames: ["command"], returns: true) { [weak consoleDisplayer] (args, completionHandler) in
		
		DispatchQueue.main.async {
			consoleDisplayer?.addTextToConsole("The captureShell function can only be used in OpenTerm.")
		}
		
		_ = completionHandler(.number(0))
		
	}
	
	
	let shellCommand = """
						The shell function can only be used in OpenTerm.
						This function is included in Savanna for testing OpenTerm script, without actually executing any commands.
						- Returns: 0
						"""
	runner.registerExternalFunction(documentation: shellCommand, name: "shell", argumentNames: ["command"], returns: true) { [weak consoleDisplayer] (args, completionHandler) in
		
		DispatchQueue.main.async {
			consoleDisplayer?.addTextToConsole("The shell function can only be used in OpenTerm.")
		}
		
		_ = completionHandler(.number(0))
		
	}
	
	let printDoc = """
						Display something on screen.
						- Parameter input: the value you want to print.
						"""
	
	runner.registerExternalFunction(documentation: printDoc, name: "print", argumentNames: ["input"], returns: true) { [weak consoleDisplayer] (args, completionHandler) in
		
		guard let input = args["input"] else {
			_ = completionHandler(.string(""))
			return
		}
		
		let parameter = input.description(with: runner.compiler)
		
		DispatchQueue.main.async {
			consoleDisplayer?.addTextToConsole(parameter)
		}
		
		_ = completionHandler(.string(""))
	}
	
	let printlnDoc = """
						Display something on screen with a new line added at the end.
						- Parameter input: the value you want to print.
						"""
	runner.registerExternalFunction(documentation: printlnDoc, name: "println", argumentNames: ["input"], returns: true) { [weak consoleDisplayer] (args, completionHandler) in
		
		guard let input = args["input"] else {
			_ = completionHandler(.string(""))
			return
		}
		
		let parameter = input.description(with: runner.compiler)
		
		DispatchQueue.main.async {
			consoleDisplayer?.addTextToConsole("\(parameter)\n")
		}
		
		_ = completionHandler(.string(""))
	}
	
	return runner
}

protocol ConsoleDisplayer: class {
	
	func clearConsole()
	
	func addTextToConsole(_ text: String)
	
}

class DocumentViewController: UIViewController, ConsoleDisplayer {

	@IBOutlet weak var contentWrapperView: UIView!
	@IBOutlet weak var contentView: UIView!
	
	@IBOutlet weak var contentStackView: UIStackView!
	
	var document: SavannaDocument?
	
	var textDocument: TextDocument? {
		guard let document = self.document else {
			return nil
		}
		
		switch document {
		case .cub(let cubDoc):
			return cubDoc
			
		case .prideland(let pridelandDoc):
			return pridelandDoc
		}
		
	}
	
	@IBOutlet weak var sourceTextView: SyntaxTextView!
	
	let autoCompleteManager = CubSyntaxAutoCompleteManager()
	let inputAssistantView = InputAssistantView()
	
	func docItems() -> [DocumentationItem] {
		return DocumentationGenerator().items(runner: getRunner(consoleDisplayer: self))
	}
	
	var autoCompleter: AutoCompleter!

	var cubManualPanelViewController: PanelViewController!
	var consolePanelViewController: PanelViewController!
	var cubDocsPanelViewController: PanelViewController!

	var consoleViewController: ConsoleViewController!

	private var textViewSelectedRangeObserver: NSKeyValueObservation?

	var manualBarButtonItem: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		autoCompleter = AutoCompleter(documentation: docItems())
		
		consoleViewController = UIStoryboard.main.consoleViewController()
		consolePanelViewController = PanelViewController(with: consoleViewController, in: self)

		let cubManualURL = Bundle.main.url(forResource: "book", withExtension: "html", subdirectory: "cub-guide.htmlcontainer")!
		let cubManualVC = UIStoryboard.main.manualWebViewController(htmlURL: cubManualURL)
		cubManualPanelViewController = PanelViewController(with: cubManualVC, in: self)
		cubManualVC.title = "The Cub Programming Language"
		
		let manualButton = UIButton(type: .system)
		manualButton.setTitle("?", for: .normal)
		manualButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
		
		manualButton.addTarget(self, action: #selector(showManual(_:)), for: .touchUpInside)
		
		manualBarButtonItem = UIBarButtonItem(customView: manualButton)
		
		let cubDocsVC = UIStoryboard.main.cubDocumentationViewController()
		cubDocsPanelViewController = PanelViewController(with: cubDocsVC, in: self)
		cubDocsVC.title = "Documentation"
		
		cubDocsPanelViewController.panelNavigationController.view.backgroundColor = .navBarColor
		cubDocsPanelViewController.view.backgroundColor = .clear
		
		let docsBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showDocs(_:)))

		self.navigationItem.rightBarButtonItems =  (self.navigationItem.rightBarButtonItems ?? []) + [manualBarButtonItem, docsBarButtonItem]
		
		sourceTextView.delegate = self
		sourceTextView.theme = Cub.DefaultTheme()
		sourceTextView.contentTextView.indicatorStyle = .white
		
//		self.navigationController?.navigationBar.shadowImage = UIImage()
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_ :)), name: .UIKeyboardWillChangeFrame, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: .UIKeyboardWillHide, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)

		sourceTextView.text = ""
		
		// Set up auto complete manager
		autoCompleteManager.delegate = inputAssistantView
		autoCompleteManager.dataSource = self
		
		// Set up input assistant and text view for auto completion
		inputAssistantView.delegate = self
		inputAssistantView.dataSource = autoCompleteManager
		inputAssistantView.attach(to: sourceTextView.contentTextView)
		
		inputAssistantView.leadingActions = [
			InputAssistantAction(image: DocumentViewController.tabImage, target: self, action: #selector(insertTab))
		]

		textDocument?.open(completionHandler: { [weak self] (success) in
			
			guard let `self` = self else {
				return
			}
			
			if success {
				
				self.sourceTextView.text = self.document?.text ?? ""
				
				// Calculate layout for full document, so scrolling is smooth.
//				self.sourceTextView.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: self.textView.text.count))
				
			} else {
				
				self.showAlert("Error", message: "Document could not be opened.", dismissCallback: {
					self.dismiss(animated: true, completion: nil)
				})
				
			}
			
		})
		
	}
	
	private static var tabImage: UIImage {
		return UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image(actions: { context in
			
			let path = UIBezierPath()
			path.move(to: CGPoint(x: 1, y: 12))
			path.addLine(to: CGPoint(x: 20, y: 12))
			path.addLine(to: CGPoint(x: 15, y: 6))

			path.move(to: CGPoint(x: 20, y: 12))
			path.addLine(to: CGPoint(x: 15, y: 18))

			path.move(to: CGPoint(x: 23, y: 6))
			path.addLine(to: CGPoint(x: 23, y: 18))

			UIColor.white.setStroke()
			path.lineWidth = 2
			path.lineCapStyle = .butt
			path.lineJoinStyle = .round
			path.stroke()

			context.cgContext.addPath(path.cgPath)
			
		}).withRenderingMode(.alwaysOriginal)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	
		savePanelStates()

		let didAllowPanelPinning = self.allowPanelPinning
		let didAllowPanelFloating = self.allowFloatingPanels

		coordinator.animate(alongsideTransition: { (ctx) in
			
			
		}, completion: { (ctx) in
		
			if !self.allowPanelPinning {
				self.closeAllPinnedPanels()
			} else if !didAllowPanelPinning {
				self.initializePanelStates()
			}
			
			if !self.allowFloatingPanels {
				self.closeAllFloatingPanels()
			}
			
		})
		
	}
	
	@objc
	func showManual(_ sender: UIButton) {
		
		presentPopover(self.cubManualPanelViewController, from: manualBarButtonItem, backgroundColor: .white)
		
	}
	
	@objc
	func showDocs(_ sender: UIBarButtonItem) {
		
		presentPopover(self.cubDocsPanelViewController, from: sender, backgroundColor: .navBarColor)
		
	}
	
	private func presentPopover(_ viewController: UIViewController, from sender: UIBarButtonItem, backgroundColor: UIColor) {
		
		// prevent a crash when the panel is floating.
		viewController.view.removeFromSuperview()
		
		viewController.modalPresentationStyle = .popover
		viewController.popoverPresentationController?.barButtonItem = sender
		viewController.popoverPresentationController?.backgroundColor = backgroundColor
		
		present(viewController, animated: true, completion: nil)
	}
	
	
	@objc func insertTab() {
		
		sourceTextView.insertText("\t")
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		sourceTextView.tintColor = self.view.tintColor
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		

	}
	
	@objc
	func applicationDidEnterBackground() {
		
		savePanelStates()
		
	}
	
	var didInitialPanelConfig = false
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if !didInitialPanelConfig {
			didInitialPanelConfig = true
			
			initializePanelStates()
			
		}
	
	}
	
	func initializePanelStates() {
		
		if !restorePanelStatesFromDisk() {
			
			self.pin(consolePanelViewController, to: .bottom, atIndex: 0)
			
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		savePanelStates()
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {

		guard let userInfo = notification.userInfo else {
			return
		}
		
		updateForKeyboard(with: userInfo, to: 0.0)

	}
	
	@objc func keyboardWillChangeFrame(_ notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		
		guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
			return
		}
		
		let convertedFrame = self.sourceTextView.convert(endFrame, from: nil).intersection(self.sourceTextView.bounds)
	
		let bottomInset = convertedFrame.size.height
		
		updateForKeyboard(with: userInfo, to: bottomInset)

	}
	
	func updateForKeyboard(with info: [AnyHashable: Any], to bottomInset: CGFloat) {

		let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
		let animationCurveRawNSN = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
		let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
		let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
		
		UIView.animate(withDuration: duration, delay: 0.0, options: [animationCurve], animations: {
			
			self.sourceTextView.contentInset.bottom = bottomInset
			
		}, completion: nil)
		
	}
	
	func clearConsole() {
		
		consoleViewController.textView.text = ""
		
	}
	
	func addTextToConsole(_ text: String) {
		
		consoleViewController.addText(text)
	}
	
	var currentBlockOperation: Thread?
	
	@IBAction func runSource(_ sender: UIBarButtonItem) {
		
		currentBlockOperation?.cancel()
		
		clearConsole()
		
		let runner = getRunner(consoleDisplayer: self)
		runner.delegate = self
		
		let source = self.sourceTextView.text
		
		let thread = Thread { [weak self] in

			do {
				
				try runner.run(source)
				
			} catch {
				print(error)
				DispatchQueue.main.async {
					
					let errorString: String
					
					if let displayableError = error as? Cub.DisplayableError {
						
						errorString = displayableError.description(inSource: source)
						
					} else {
						
						errorString = "Unknown error occurred"
						
					}
					
					self?.addTextToConsole("\(errorString)\n")
					
				}
				
			}
			
		}
		
		currentBlockOperation = thread

		thread.start()
		
	}
	
	@IBAction func dismissDocumentViewController() {
		
		let currentText = self.document?.text ?? ""
		
		self.textDocument?.text = self.sourceTextView.text
		
		if currentText != self.sourceTextView.text {
			self.textDocument?.updateChangeCount(.done)
		}
		
		dismiss(animated: true) {
			self.textDocument?.close(completionHandler: nil)
		}
	}
	
}

extension DocumentViewController: Cub.RunnerDelegate {
	
	@nonobjc func log(_ message: String) {
		// TODO: refactor to function, scroll to bottom
		addTextToConsole("\n\(message)")

		print(message)
	}
	
	@nonobjc func log(_ error: Error) {
		
		addTextToConsole("\n\(error)")

		print(error)
	}
	
	@nonobjc func log(_ token: Cub.Token) {
		
		addTextToConsole("\n\(token)")

		print(token)
	}
	
}

extension DocumentViewController: SyntaxTextViewDelegate {

	func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
		autoCompleteManager.reloadData()
	}
	
	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		autoCompleteManager.reloadData()
	}
	
	func lexerForSource(_ source: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: source)
	}
	
}

extension DocumentViewController: CubSyntaxAutoCompleteManagerDataSource {
	
	func completions() -> [CubSyntaxAutoCompleteManager.Completion] {
		
		guard let text = sourceTextView.contentTextView.text else {
			return []
		}
		
		let selectedRange = sourceTextView.contentTextView.selectedRange
		
		guard let swiftRange = Range(selectedRange, in: text) else {
			return []
		}
		
		let cursor = text.distance(from: text.startIndex, to: swiftRange.lowerBound)
		
		let suggestions = autoCompleter.completionSuggestions(for: sourceTextView.contentTextView.text, cursor: cursor)
		
		return suggestions.map({ CubSyntaxAutoCompleteManager.Completion($0.content, data: $0) })
	}
	
}

extension DocumentViewController: InputAssistantViewDelegate {
	
	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		let completion = autoCompleteManager.completions[index]
		
		let suggestion = completion.data
		
		sourceTextView.insertText(suggestion.content)
		
		let newSource = sourceTextView.text
		
		let insertStart = newSource.index(newSource.startIndex, offsetBy: suggestion.insertionIndex)
		let cursorAfterInsertion = newSource.index(insertStart, offsetBy: suggestion.cursorAfterInsertion)
		
		if let utf16Index = cursorAfterInsertion.samePosition(in: newSource) {
			let distance = newSource.utf16.distance(from: newSource.utf16.startIndex, to: utf16Index)
			
			sourceTextView.contentTextView.selectedRange = NSRange(location: distance, length: 0)
		}
		
	}
	
}

extension DocumentViewController: PanelManager {
	
	var panels: [PanelViewController] {
		return [cubManualPanelViewController, consolePanelViewController, cubDocsPanelViewController]
	}
	
	var panelContentWrapperView: UIView {
		return self.contentWrapperView
	}
	
	var panelContentView: UIView {
		return self.contentView
	}
	
	func maximumNumberOfPanelsPinned(at side: PanelPinSide) -> Int {
		return 2
	}
	
}

extension DocumentViewController {
	
	@objc
	func savePanelStates() {
		
		guard self.allowPanelPinning else {
			return
		}
		
		let states = self.panelStates
		
		let encoder = PropertyListEncoder()
		
		guard let data = try? encoder.encode(states) else {
			return
		}
		
		UserDefaults.standard.set(data, forKey: "panelStates")
		
	}
	
	func getStatesFromDisk() -> [Int: PanelState]? {
		
		guard let data = UserDefaults.standard.data(forKey: "panelStates") else {
			return nil
		}
		
		let decoder = PropertyListDecoder()
		
		guard let states = try? decoder.decode([Int: PanelState].self, from: data) else {
			return nil
		}
		
		return states
	}
	
	func restorePanelStatesFromDisk() -> Bool {
		
		if let statesFromDisk = getStatesFromDisk(), !statesFromDisk.isEmpty {
			restorePanelStates(statesFromDisk)
			return true
		} else {
			return false
		}
		
	}
	
}
