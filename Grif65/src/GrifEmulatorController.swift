//
// Created by Andy Best on 22/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

class GrifEmulatorController : GrifEmulatorDelegate, SerialEmulatorDelegate {

    var serialWindowController: SerialEmulatorWindowController?
    var emulator = GrifEmulator()
    var timer: Timer?

    init() {
        self.serialWindowController = SerialEmulatorWindowController(windowNibName: "SerialEmulatorWindow")
        self.serialWindowController!.showWindow(self)
        self.serialWindowController!.delegate = self

        emulator.delegate = self
        emulator.cpu.loadHexFileToMemory("/Users/andybest/dev/swift/Grif65/target_software/iotest/build/output.hex")
        //emulator.cpu.loadHexFileToMemory("/Users/andybest/Downloads/as65/TEST.HEX")
        //emulator.cpu.setMemFromHexString("a5 00 8d 03 02 69 01 4c 02 06 ", address: 0x600)
        //emulator.cpu.setMemFromHexString("4C1103A000B100F0078D0302C84C050360A2FF9AD8A9238500A90385012003034C200348656C6C6F2C20776F726C6400", address:0x300)
        emulator.cpu.setProgramCounter(0x300)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        _ = emulator.cpu.runCycles(10000)
    }


    // MARK - GrifEmulatorDelegate
    func emulatorDidSendSerial(_ value: UInt8) {
        self.serialWindowController!.processSerialData(value)
    }
    
    // MARK - SerialEmulatorDelegate
    func consoleDidSendSerial(_ value: UInt8) {
        self.emulator.duart.serialChannelReceive(value, channel: DUARTSerialChannel.serialChannelA)
    }

}
