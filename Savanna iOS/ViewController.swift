//
//  ViewController.swift
//  Savanna iOS
//
//  Created by Louis D'hauwe on 30/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import UIKit
import Lioness
import SavannaKit

class IOSViewController: UIViewController, RunnerDelegate {

	@IBOutlet weak var consoleLogTextView: UITextView!
	@IBOutlet weak var sourceTextView: SyntaxTextView!

	@IBOutlet weak var stackView: UIStackView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		self.navigationController?.navigationBar.shadowImage = UIImage()
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_ :)), name: .UIKeyboardWillChangeFrame, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: .UIKeyboardWillHide, object: nil)

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		sourceTextView.tintColor = self.view.tintColor
		
	}
	
	func keyboardWillHide(_ notification: NSNotification) {

		guard let userInfo = notification.userInfo else {
			return
		}
		
		updateForKeyboard(with: userInfo, to: 0.0)

	}
	
	func keyboardWillChangeFrame(_ notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		
		let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
	
		var bottomInset = endFrame?.size.height ?? 0.0
		
		if stackView.axis == .vertical {
			bottomInset -= consoleLogTextView.bounds.height
		}
		
		updateForKeyboard(with: userInfo, to: bottomInset)

	}
	
	func updateForKeyboard(with info: [AnyHashable : Any], to bottomInset: CGFloat) {

		let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
		let animationCurveRawNSN = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
		let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
		let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
		
		UIView.animate(withDuration: duration, delay: 0.0, options: [animationCurve], animations: {
			
			self.sourceTextView.contentInset.bottom = bottomInset
			
		}, completion: nil)
		
	}
	
	@IBAction func toggleAxis(_ sender: UIBarButtonItem) {
	
		UIView.animate(withDuration: 0.3) {
			
			if self.stackView.axis == .horizontal {
				self.stackView.axis = .vertical
			} else {
				self.stackView.axis = .horizontal
			}
			
		}
		
	}
	
	@IBAction func runSource(_ sender: UIBarButtonItem) {
		
		consoleLogTextView.text = ""
		
		let runner = Runner(logDebug: true , logTime: true)
		runner.delegate = self
		
		do {
			
			try runner.run(sourceTextView.text)
			
		} catch {
			print("error: \(error)")
			return
		}
		
	}
	
	// MARK: -
	// MARK: Lioness Runner Delegate
	
	@nonobjc func log(_ message: String) {
		// TODO: refactor to function, scroll to bottom
		consoleLogTextView.text! += "\n\(message)"

		print(message)
	}
	
	@nonobjc func log(_ error: Error) {
		
		consoleLogTextView.text! += "\n\(error)"

		print(error)
	}
	
	@nonobjc func log(_ token: Token) {
		
		consoleLogTextView.text! += "\n\(token)"

		print(token)
	}
	
}


