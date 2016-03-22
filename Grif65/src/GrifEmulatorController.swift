//
// Created by Andy Best on 22/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

class GrifEmulatorController : GrifEmulatorDelegate {

    var serialWindowController: SerialEmulatorWindowController?

    init() {
        self.serialWindowController = SerialEmulatorWindowController(windowNibName: "SerialEmulatorWindow")
        self.serialWindowController!.showWindow(self)

        var emulator = GrifEmulator()
        emulator.delegate = self
        emulator.cpu.setMemFromHexString("a5 00 8d 03 02 69 01 4c 02 06 ", address: 0x600)
        emulator.cpu.setProgramCounter(0x600)
        emulator.cpu.runCycles(10000)
    }

    // MARK - GrifEmulatorDelegate
    func emulatorDidSendSerial(value: UInt8) {
        self.serialWindowController!.processSerialData(value)
    }

}
