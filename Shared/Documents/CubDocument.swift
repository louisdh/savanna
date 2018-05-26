//
//  CubDocument.swift
//  Savanna
//
//  Created by Louis D'hauwe on 20/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#endif

enum CubDocumentError: Error {
	case saveError
	case loadDataError
	case loadStringError
}

class TextDocument: Document {

	var text = ""

}

class CubDocument: TextDocument {
	
	func contents() throws -> Data {
		
		guard let data = text.data(using: .utf8) else {
			throw CubDocumentError.saveError
		}
		
		return data
	}
	
	func load(fromContents contents: Any) throws {
	
		guard let data = contents as? Data else {
			throw CubDocumentError.loadDataError
		}
		
		guard let utf8 = String(data: data, encoding: .utf8) else {
			throw CubDocumentError.loadStringError
		}
		
		self.text = utf8
		
	}
	
	#if os(iOS)

	override func contents(forType typeName: String) throws -> Any {
		return try contents()
	}
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		try load(fromContents: contents)
	}
	
	#endif
	
	#if os(macOS)
	
	override class var autosavesInPlace: Bool {
		return true
	}
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}
	
	override func data(ofType typeName: String) throws -> Data {
		return try contents()
	}
	
	override func read(from data: Data, ofType typeName: String) throws {
		try load(fromContents: data)
	}
	
	
	#endif
	
}
