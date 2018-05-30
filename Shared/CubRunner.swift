//
//  CubRunner.swift
//  Savanna
//
//  Created by Louis D'hauwe on 30/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub

protocol ConsoleDisplayer: class {
	
	func clearConsole()
	
	func addTextToConsole(_ text: String)
	
}

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
