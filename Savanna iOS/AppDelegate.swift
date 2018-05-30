//
//  AppDelegate.swift
//  Savanna iOS
//
//  Created by Louis D'hauwe on 30/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, COSTouchVisualizerWindowDelegate {

	var window: UIWindow?

//	var customWindow: COSTouchVisualizerWindow?
//
//	var window: UIWindow? {
//		set {
//
//		}
//		get {
//
//			if customWindow != nil {
//				return customWindow
//			}
//
//			customWindow = COSTouchVisualizerWindow(frame: UIScreen.main.bounds)
//			customWindow?.touchVisualizerWindowDelegate = self
//
//			customWindow?.fillColor = .appTintColor
//			customWindow?.strokeColor = .white
//			customWindow?.touchAlpha = 0.4
//
//			customWindow?.rippleFillColor = .appTintColor
//			customWindow?.rippleStrokeColor = .white
//
//			return customWindow
//
//		}
//	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		window?.tintColor = .appTintColor

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(_ app: UIApplication, open inputURL: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		// Ensure the URL is a file URL
		guard inputURL.isFileURL else {
			return false
		}
		
		// Reveal / import the document at the URL
		guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else {
			return false
		}
		
		documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
			if let error = error {
				// Handle the error appropriately
				print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
				return
			}
			
			// Present the Document View Controller for the revealed URL
			documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
		}
		
		return true
	}

	func touchVisualizerWindowShouldAlwaysShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
		// Return YES to make the fingertip always display even if there's no any mirrored screen.
		// Return NO or don't implement this method if you want to keep the fingertip display only when
		// the device is connected to a mirrored screen.
		return true
	}
	
	func touchVisualizerWindowShouldShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
		// Return YES or don't implement this method to make this window show fingertip when necessary.
		// Return NO to make this window not to show fingertip.
		return true
	}
	
}

