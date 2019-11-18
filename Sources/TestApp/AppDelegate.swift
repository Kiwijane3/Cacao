//
//  AppDelegate.swift
//  TestApp
//
//  Created by Jane Fraser on 11/01/19.
//

import Foundation

import Cacao

internal class AppDelegate: UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		debugPrint("Working directory is \(FileManager.default.currentDirectoryPath)");
		UIWindowController(withRootController: UINavigationController(rootViewController: WindowBarTestController()));
		return true;
	}
	
}
