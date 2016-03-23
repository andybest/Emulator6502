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
        emulator.cpu.setMemFromHexString("A954850AA903850BA900A8A200F00A910AC8D0FBE60BCAD0F6C000F005910AC8D0F760A000F007A970A2034C2F03608D3D038E3E038D44038E450388B9FFFF8D4E0388B9FFFF8D4D038C500320FFFFA0FFD0E860A2FF9AD8A9008502A900850320000320A703202303209E0320D4030040DABA48E8E8BD00012910D00368FA404C800385008601A000B2008D0202C8B100D0F8A90D8D0202A90A8D020260A9E0A20320830380F7A92F850AA903850BA92F850CA903850DA2DAA9FF8512A000E8F00DB10A910CC8D0F6E60BE60DD0F0E612D0EF60A000F007A970A2034C2F036048656C6C6F20576F726C6421", address:0x300)
        emulator.cpu.setProgramCounter(0x0354)
        emulator.cpu.runCycles(10000)
    }

    // MARK - GrifEmulatorDelegate
    func emulatorDidSendSerial(value: UInt8) {
        self.serialWindowController!.processSerialData(value)
    }

}
