//
//  PridelandDocument.swift
//  Savanna
//
//  Created by Louis D'hauwe on 20/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#endif


enum PridelandDocumentError: Error {
	case invalidDocument
}

class PridelandDocument: TextDocument {
		
	var metadata: PridelandMetadata?
	
	func contents() throws -> FileWrapper {
		
		let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
		
		let contentsFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
		contentsFileWrapper.preferredFilename = "contents"
		
		guard let textData = text.data(using: .utf8) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let cubFileWrapper = FileWrapper(regularFileWithContents: textData)
		cubFileWrapper.preferredFilename = "1.cub"
		
		contentsFileWrapper.addFileWrapper(cubFileWrapper)
		fileWrapper.addFileWrapper(contentsFileWrapper)
		
		guard let metadata = metadata else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let decoder = PropertyListEncoder()
		decoder.outputFormat = .xml
		
		guard let metadataData = try? decoder.encode(metadata) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let metadataFileWrapper = FileWrapper(regularFileWithContents: metadataData)
		metadataFileWrapper.preferredFilename = "metadata.plist"
		fileWrapper.addFileWrapper(metadataFileWrapper)
		
		return fileWrapper
	}
	
	func read(from fileWrapper: FileWrapper) throws {
		
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
	
	#if os(iOS)
	
	override func contents(forType typeName: String) throws -> Any {
		return try contents()
	}
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		
		guard let fileWrapper = contents as? FileWrapper else {
			throw PridelandDocumentError.invalidDocument
		}
		
		try read(from: fileWrapper)
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
	
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		
		try read(from: fileWrapper)
	}
	
	override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
		return try contents()
	}
	
	#endif
	
}

struct PridelandMetadata: Codable, Equatable {
	
	let name: String
	let description: String
	let hueTint: Double
	
}
