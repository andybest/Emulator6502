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




    func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application

        var cpu = CPU6502()

    }


    func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
    }




}
