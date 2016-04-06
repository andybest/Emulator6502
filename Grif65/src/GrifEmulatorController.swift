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
        //emulator.cpu.setMemFromHexString("a5 00 8d 03 02 69 01 4c 02 06 ", address: 0x600)
        emulator.cpu.setMemFromHexString("A2FF9AD8200A034C1B03A200BD1E03E8C900F0068D03024C0C03604C1B0348656C6C6F2C20776F726C6400", address:0x300)
        emulator.cpu.setProgramCounter(0x0300)
        emulator.cpu.runCycles(500)
    }

    // MARK - GrifEmulatorDelegate
    func emulatorDidSendSerial(value: UInt8) {
        self.serialWindowController!.processSerialData(value)
    }

}
