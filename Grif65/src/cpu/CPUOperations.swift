//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

/*
        switch mode {

        case .Immediate(let val):
            break
        case .ZeroPage(let val):
            break
        case .ZeroPageX(let val):
            break
        case .Absolute(let val):
            break
        case .AbsoluteX(let val):
            break
        case .AbsoluteY(let val):
            break
        case .Indirect(let val):
            break
        case .IndirectX(let val):
            break
        case .IndirectY(let val):
            break
        }
        */

// Operations

extension CPU6502 {

    func clearCarry() {
        registers.setCarryFlag(false)
    }

    func calculateCarry(value: UInt16) -> Bool {
        return value & 0xFF00 > 0
    }

    func calculateZero(value: UInt16) -> Bool {
        return value & 0x00FF == 0
    }

    func calculateOverflow(result: UInt16, acc: UInt8, value: UInt8) -> Bool {
        return ((result ^ UInt16(acc)) & (result ^ UInt16(value)) & 0x0080) > UInt16(0)
    }

    func calculateSign(value: UInt16) -> Bool {
        // Value > 127
        return value & 0x0080 > 0
    }

    func getIndirect(address: UInt8) -> UInt8 {
        let addr = UInt16(address)
        let indirectAddress: UInt16 = UInt16(getMem(addr)) | (UInt16(getMem(addr + 1)) << 8)
        return getMem(indirectAddress | ((indirectAddress + 1) << 8))
    }

    func getIndirectX(address: UInt8) -> UInt8 {
        return getIndirect(address + registers.x)
    }

    func getIndirectY(address: UInt8) -> UInt8 {
        let addr = UInt16(address)
        let indirectAddress: UInt16 = UInt16(getMem(addr)) | (UInt16(getMem(addr + 1)) << 8) + UInt16(registers.y)
        return getMem(indirectAddress | ((indirectAddress + 1) << 8))
    }

    func valueForAddressingMode(mode: AddressingMode) -> UInt8 {
        switch mode {
        case .Immediate(let val):
            return val
        case .ZeroPage(let val):
            return getZero(val)
        case .ZeroPageX(let val):
            return getZero(val + registers.x)
        case .Absolute(let val):
            return getMem(val)
        case .AbsoluteX(let val):
            return getMem(val + UInt16(registers.x))
        case .AbsoluteY(let val):
            return getMem(val + UInt16(registers.y))
        case .Indirect(let val):
            return getIndirect(val)
        case .IndirectX(let val):
            return getIndirectX(val)
        case .IndirectY(let val):
            return getIndirectY(val)
        }
    }

    func opADC(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)

        // Add the value to accumulator, add 1 if carry flag is active
        let newVal: UInt16 = UInt16(registers.a) +
                UInt16(value) +
                UInt16(registers.boolToInt(registers.getCarryFlag()))

        registers.setCarryFlag(calculateCarry(newVal))
        registers.setZeroFlag(calculateZero(newVal))
        registers.setOverflowFlag(calculateOverflow(newVal, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(newVal))

        registers.a = UInt8(newVal & UInt16(0xFF))
    }
}