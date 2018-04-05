//
//  Prideland.swift
//  Savanna macOS
//
//  Created by Louis D'hauwe on 01/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Cocoa

enum PridelandDocumentError: Error {
	case invalidDocument
}

class PridelandDocument: NSDocument {

	var text = ""
	
	var metadata: PridelandMetadata?

	override init() {
		super.init()
		// Add your subclass-specific initialization here.
	}
	
	override class var autosavesInPlace: Bool {
		return true
	}
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}
	
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		
		guard let wrappers = fileWrapper.fileWrappers else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let contentsWrapper = wrappers["contents"]
		
		guard let cubContentsWrapper = contentsWrapper?.fileWrappers?["1.cub"] else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let textData = cubContentsWrapper.regularFileContents else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let text = String(data: textData, encoding: .utf8) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let metadataData = wrappers["metadata.plist"]?.regularFileContents else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let decoder = PropertyListDecoder()
		
		guard let metadata = try? decoder.decode(PridelandMetadata.self, from: metadataData) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		self.text = text
		self.metadata = metadata
		
	}
	
}

struct PridelandMetadata: Codable, Equatable {
	
	let name: String
	let description: String
	let hueTint: Double
	
}
