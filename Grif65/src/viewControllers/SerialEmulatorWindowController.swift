//
//  SerialEmulatorWindowController.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Cocoa

protocol SerialEmulatorDelegate {
    func consoleDidSendSerial(_ value: UInt8)
}

class SerialEmulatorWindowController: NSWindowController, GrifConsoleDelegate {

    @IBOutlet var serialTextView: GrifConsoleTextView!
    var delegate: SerialEmulatorDelegate?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window!.makeKeyAndOrderFront(self)

        initSerialTextView()
        serialTextView.delegate = self
    }

    func initSerialTextView() {
    }

    func processSerialData(_ value: UInt8) {
        serialTextView.processSerialData(value)
    }
    
    // GrifConsoleDelegate
    func consoleDidSendSerial(_ value: UInt8) {
        if self.delegate != nil {
            self.delegate!.consoleDidSendSerial(value)
        }
    }
}
