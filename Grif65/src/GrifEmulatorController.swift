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
        emulator.delegate = self
        
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
