//
//  MacManualWebViewController.swift
//  Savanna macOS
//
//  Created by Louis D'hauwe on 30/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import AppKit
import WebKit

class MacManualWebWindowController: NSWindowController {
	
}

class MacManualWebViewController: NSViewController {

	@IBOutlet weak var webView: WKWebView!
	
	var htmlURL: URL!

	override func viewDidLoad() {
		super.viewDidLoad()

		let cubManualURL = Bundle.main.url(forResource: "book", withExtension: "html", subdirectory: "cub-guide.htmlcontainer")!
		htmlURL = cubManualURL
		webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
	
		self.title = "The Cub Programming Language"

	}
}

