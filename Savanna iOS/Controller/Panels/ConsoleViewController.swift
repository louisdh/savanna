//
//  ConsoleViewController.swift
//  Savanna iOS
//
//  Created by Louis D'hauwe on 27/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit

class ConsoleViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationController?.navigationBar.barStyle = .black
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationController?.navigationBar.barTintColor = .navBarColor
		
    }
	
	func addText(_ text: String) {
		
		textView.text = (textView.text ?? "") + text
		
	}
	
	@IBAction
	func clearConsole(_ sender: UIBarButtonItem) {
		
		textView.text = ""
	}

}


extension ConsoleViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "ConsoleViewController"
	}
	
}

extension ConsoleViewController: PanelContentDelegate {
	
	var preferredPanelContentSize: CGSize {
		return CGSize(width: 420, height: 480)
	}
	
	var preferredPanelPinnedWidth: CGFloat {
		return 320
	}
	
	var preferredPanelPinnedHeight: CGFloat {
		return 240
	}
	
	var minimumPanelContentSize: CGSize {
		return CGSize(width: 320, height: 320)
	}
	
	var maximumPanelContentSize: CGSize {
		return CGSize(width: 600, height: 1400)
	}
	
	var shouldAdjustForKeyboard: Bool {
		return false
	}
	
	var rightBarButtonItems: [UIBarButtonItem] {
		let clearItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearConsole(_:)))
		return [clearItem]
	}
	
	var hideCloseButtonWhileFloating: Bool {
		return true
	}
	
	var hideCloseButtonWhilePinned: Bool {
		return true
	}
}
