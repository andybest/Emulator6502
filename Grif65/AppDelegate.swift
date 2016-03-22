//
//  AppDelegate.swift
//  Grif65
//
//  Created by Andy Best on 09/03/2016.
//  Copyright (c) 2016 andybest. All rights reserved.
//


import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var emulatorController: GrifEmulatorController?

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.emulatorController = GrifEmulatorController()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}
