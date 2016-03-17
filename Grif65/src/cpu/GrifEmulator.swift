//
//  GrifEmulator.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Foundation

protocol IODevice {
    func writeMem(address: UInt8, value: UInt8)

    func readMem(address: UInt8) -> UInt8
}

class GrifEmulator {

    var ioDevices: [IODevice]
    var cpu:       CPU6502
    var ram:       [UInt8]

    init() {
        ram = [UInt8](count: 0xFFFF, repeatedValue: 0)
        ioDevices = [IODevice]()
        ioDevices.append(DUART())

        cpu = CPU6502()
        cpu.readMemoryCallback = readMemory
        cpu.writeMemoryCallback = writeMemory
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

        return dev.readMem(address)
    }

    func writePeripheral(address: UInt8, value: UInt8) {
        guard let dev = ioDeviceForAddress(address) else {
            return
        }

        dev.writeMem(address, value: value)
    }

}