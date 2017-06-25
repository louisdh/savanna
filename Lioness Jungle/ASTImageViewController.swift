//
//  ASTImageViewController.swift
//  Lioness Jungle
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import AppKit

class ASTImageViewController: NSViewController {

	@IBOutlet weak var imageView: NSImageView!
	
	override func mouseDown(with theEvent: NSEvent) {
		print("Mouse Clicked")
	}
	
	override func keyDown(with theEvent: NSEvent) {
		print("Key Pressed")
	}
	
}
