//
//  GrifEmulator.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Foundation

protocol IODevice {
    func writeMemory(address: UInt8, value: UInt8)

    func readMemory(address: UInt8) -> UInt8

    func attachInterruptHandler(handler: (Void) -> (Void))
}

protocol GrifEmulatorDelegate {
    func emulatorDidSendSerial(value: UInt8)
}

class GrifEmulator {

    var ioDevices: [IODevice]
    var cpu:       CPU6502
    var ram:       [UInt8]
    var delegate:  GrifEmulatorDelegate?

    var duart: DUART

    init() {
        ram = [UInt8](count: 0xFFFF, repeatedValue: 0)
        ioDevices = [IODevice]()

        duart = DUART()
        ioDevices.append(duart)

        cpu = CPU6502()
        cpu.readMemoryCallback = readMemory
        cpu.writeMemoryCallback = writeMemory

        duart.attachSerialChannelSendCallback(serialChannelDidSend)
    }

    func readMemory(address: UInt16) -> UInt8 {
        if (address >= 0x200 && address < 0x300) {
            return readPeripheral(UInt8(address & 0x00FF))
        } else {
            return ram[Int(address)]
        }
    }

    func writeMemory(address: UInt16, value: UInt8) {
        if (address >= 0x200 && address < 0x300) {
            writePeripheral(UInt8(address & 0x00FF), value: value)
        } else {
            ram[Int(address)] = value
        }
    }

    func ioDeviceForAddress(address: UInt8) -> IODevice? {
        let deviceNum = Int((address & 0xF) >> 4)

        if ioDevices.count > deviceNum {
            return ioDevices[deviceNum]
        }

        return nil
    }

    func readPeripheral(address: UInt8) -> UInt8 {
        guard let dev = ioDeviceForAddress(address) else {
            return 0
        }

        return dev.readMemory(address)
    }

    func writePeripheral(address: UInt8, value: UInt8) {
        guard let dev = ioDeviceForAddress(address) else {
            return
        }

        dev.writeMemory(address, value: value)
    }

    func serialChannelDidSend(value: UInt8, channel: DUARTSerialChannel) {
        if self.delegate != nil {
            self.delegate!.emulatorDidSendSerial(value)
        }
    }

}