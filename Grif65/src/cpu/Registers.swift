//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

struct Registers {
    var a: UInt8
    var x: UInt8
    var y: UInt8

    /* Status Flags */
    var p: UInt8

    /* Stack Pointer */
    var s: UInt8

    /* Program Counter */
    var pc: UInt16

    init() {
        self.p = 0b00100000 // Set bit 5 of status flag to 1

        self.a = 0
        self.x = 0
        self.y = 0

        self.s = 0
        self.pc = 0
    }

    func stateString() -> String {
        let aStr = String(format:"0x%02X", self.a)
        let xStr = String(format:"0x%02X", self.x)
        let yStr = String(format:"0x%02X", self.y)

        return "A: \(aStr), X:\(xStr), Y:\(yStr)"
    }

    func boolToInt(_ value: Bool) -> UInt8 {
        if value {
            return 1
        }
        return 0
    }

    func getStatusByte() -> UInt8 {
        return p
    }

    mutating func setStatusByte(_ value: UInt8) {
        p = value
    }

    func getCarryFlag() -> Bool {
        return (p & 0b00000001) == 1
    }

    mutating func setCarryFlag(_ value: Bool) {
        p = (p & 0b11111110) | boolToInt(value)
    }

    func getZeroFlag() -> Bool {
        return ((p & 0b00000010) >> 1) == 1
    }

    mutating func setZeroFlag(_ value: Bool) {
        p = (p & 0b11111101) | boolToInt(value) << 1
    }

    func getInterruptFlag() -> Bool {
        return ((p & 0b00000100) >> 2) == 1
    }

    mutating func setInterruptFlag(_ value: Bool) {
        p = (p & 0b11111011) | boolToInt(value) << 2
    }

    func getDecimalFlag() -> Bool {
        return ((p & 0b00001000) >> 3) == 1
    }

    mutating func setDecimalFlag(_ value: Bool) {
        p = (p & 0b11110111) | boolToInt(value) << 3
    }

    func getBreakFlag() -> Bool {
        return ((p & 0b00010000) >> 4) == 1
    }

    mutating func setBreakFlag(_ value: Bool) {
        p = (p & 0b11101111) | boolToInt(value) << 4
    }

    func getOverflowFlag() -> Bool {
        return ((p & 0b01000000) >> 6) == 1
    }

    mutating func setOverflowFlag(_ value: Bool) {
        p = (p & 0b10111111) | boolToInt(value) << 6
    }

    func getSignFlag() -> Bool {
        return ((p & 0b10000000) >> 7) == 1
    }

    mutating func setSignFlag(_ value: Bool) {
        p = (p & 0b01111111) | boolToInt(value) << 7
    }
}
