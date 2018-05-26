//
//  Document.swift
//  Savanna
//
//  Created by Louis D'hauwe on 20/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if canImport(UIKit)
	import UIKit
	typealias Document = UIDocument
#else
	import AppKit
	typealias Document = NSDocument
#endif

//protocol Document {
//
//	func contents(forType typeName: String) throws -> Any
//
//	func load(fromContents contents: Any, ofType typeName: String?) throws
//
//}

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
