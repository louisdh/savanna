//
//  Cub+SavannaKit.swift
//  Savanna iOS
//
//  Created by Louis D'hauwe on 07/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub
import SavannaKit
import Lioness

extension Cub.TokenType: SavannaKit.TokenType {
	
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
			
		case .squareBracketOpen:
			return .plain
			
		case .squareBracketClose:
			return .plain
			
		case .editorPlaceholder(_):
			return .editorPlaceholder

		}
		
	}
	
}

extension Cub.Token: SavannaKit.Token {
	
	public var skRange: Range<Int>? {
		return self.range
	}
	
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
	public var skRange: Range<Int>? {
		return self.range
	}
	
	
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
