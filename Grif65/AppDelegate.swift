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


    @IBOutlet weak var window: NSWindow!
    var serialWindowController: SerialEmulatorWindowController?

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        self.serialWindowController = SerialEmulatorWindowController(windowNibName: "SerialEmulatorWindow")
        self.serialWindowController!.showWindow(self)

        var emulator = GrifEmulator()
        emulator.cpu.setMemFromHexString("A2 FF 9A A9 05 85 00 A9 03 85 01 20 11 02 4C 0E 02 A5 00 65 01 60", address: 0x200)
        emulator.cpu.runCycles(30)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}
