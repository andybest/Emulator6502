//
//  GrifEmulator.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Foundation

protocol IODevice {
    func writeMemory(_ address: UInt8, value: UInt8)

    func readMemory(_ address: UInt8) -> UInt8

    func attachInterruptHandler(_ handler: @escaping (Void) -> (Void))
}

protocol GrifEmulatorDelegate {
    func emulatorDidSendSerial(_ value: UInt8)
}

/* 
 MEMORY MAP
 ==========
 
 $0000-$00FF: Zero Page RAM
 $0100-$01FF: Stack Ram
 $0200-$02FF: I/O Space
 $0300-$BFFF: RAM
 $C000-$FFFF: ROM
 
 */

class GrifEmulator {

    var ioDevices: [IODevice]
    var cpu:       CPU6502
    var ram:       [UInt8]
    var rom:       [UInt8]
    var delegate:  GrifEmulatorDelegate?

    var duart: DUART

    init() {
        ram = [UInt8](repeating: 0, count: 0x10000 + 1)
        rom = [UInt8](repeating: 0, count: 0x4000)
        ioDevices = [IODevice]()

        duart = DUART()
        ioDevices.append(duart)

        cpu = CPU6502()
        cpu.readMemoryCallback = readMemory
        cpu.writeMemoryCallback = writeMemory

        duart.attachSerialChannelSendCallback(serialChannelDidSend)
        loadRom()

        cpu.reset()
    }
    
    func loadRom() {
        let romPath = Bundle.main.path(forResource: "romimage", ofType: "bin")
        
        do {
            let romData = try Data(contentsOf: URL(fileURLWithPath: romPath!))
            
            for i in 2..<romData.count - 1 {
                rom[i - 2] = romData[i]
            }
        } catch {
            print(error)
        }
    }

    func readMemory(_ address: UInt16) -> UInt8 {
        if address >= 0x200 && address < 0x300 {
            return readPeripheral(UInt8(address & 0x00FF))
        } else if address >= 0x4000 {
            return rom[Int(address & 0x3FFF)]
        } else {
            return ram[Int(address)]
        }
    }

    func writeMemory(_ address: UInt16, value: UInt8) {
        if address >= 0x200 && address < 0x300 {
            writePeripheral(UInt8(address & 0x00FF), value: value)
        } else if address > 0x4000 {
            print("ERROR! Tried to write to a ROM address: \(address).")
        } else {
            ram[Int(address)] = value
        }
    }

    func ioDeviceForAddress(_ address: UInt8) -> IODevice? {
        let deviceNum = Int((address & 0xF) >> 4)

        if ioDevices.count > deviceNum {
            return ioDevices[deviceNum]
        }

        return nil
    }

    func readPeripheral(_ address: UInt8) -> UInt8 {
        guard let dev = ioDeviceForAddress(address) else {
            return 0
        }

        return dev.readMemory(address)
    }

    func writePeripheral(_ address: UInt8, value: UInt8) {
        guard let dev = ioDeviceForAddress(address) else {
            return
        }

        dev.writeMemory(address, value: value)
    }

    func serialChannelDidSend(_ value: UInt8, channel: DUARTSerialChannel) {
        if self.delegate != nil {
            self.delegate!.emulatorDidSendSerial(value)
        }
    }

}
