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
        default: // This should raise an exception
            return 0
        }
    }

    func addressForAddressingMode(mode: AddressingMode) -> UInt16 {
        switch mode {
        case .Immediate(let val):
            return UInt16(val)
        case .ZeroPage(let val):
            return UInt16(val)
        case .ZeroPageX(let val):
            return UInt16(val + registers.x)
        case .Absolute(let val):
            return val
        case .AbsoluteX(let val):
            return val + UInt16(registers.x)
        case .AbsoluteY(let val):
            return val + UInt16(registers.y)
        case .Indirect(let val):
            return UInt16(getIndirect(val))
        case .IndirectX(let val):
            return UInt16(getIndirectX(val))
        case .IndirectY(let val):
            return UInt16(getIndirectY(val))
        default: // This should raise an exception
            return 0
        }
    }

    func opADC(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)

        // Add the value to accumulator, add 1 if carry flag is active
        let result: UInt16 = UInt16(registers.a) +
                UInt16(value) +
                UInt16(registers.boolToInt(registers.getCarryFlag()))

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setOverflowFlag(calculateOverflow(result, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(result))

        registers.a = UInt8(result & UInt16(0xFF))
    }

    func opAND(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)

        registers.a &= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
    }

    func opASL(mode: AddressingMode) {
        let result:UInt16 = UInt16(registers.a) << UInt16(1);

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        registers.a = UInt8(result & 0xFF)
    }

    func opBCC(mode: AddressingMode) {
        if !registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBCS(mode: AddressingMode) {
        if registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBEQ(mode: AddressingMode) {
        if registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBIT(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        let result = UInt16(registers.a) & UInt16(value)

        registers.setZeroFlag(calculateZero(result))
        registers.setOverflowFlag(calculateOverflow(result, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(result))
    }

    func opBMI(mode: AddressingMode) {
        if registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBNE(mode: AddressingMode) {
        if !registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBPL(mode: AddressingMode) {
        if !registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBRK(mode: AddressingMode) {

    }

    func opBVC(mode: AddressingMode) {
        if !registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opBVS(mode: AddressingMode) {
        if registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
        }
    }

    func opCLC(mode: AddressingMode) {
        registers.setCarryFlag(false)
    }

    func opCLD(mode: AddressingMode) {
        registers.setDecimalFlag(false)
    }

    func opCLI(mode: AddressingMode) {
        registers.setInterruptFlag(false)
    }

    func opCLV(mode: AddressingMode) {
        registers.setOverflowFlag(false)
    }

    func opCMP(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt16(registers.a) - UInt16(value)

        if registers.a >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.a == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(result))
    }

    func opCPX(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt16(registers.x) - UInt16(value)

        if registers.x >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.x == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(result))
    }

    func opCPY(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt16(registers.y) - UInt16(value)

        if registers.y >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.y == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(result))
    }

    func opDEC(mode: AddressingMode) {
        let result = UInt16(registers.a) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.a = UInt8(result & 0xFF)
    }

    func opDEX(mode: AddressingMode) {
        let result = UInt16(registers.x) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
    }

    func opDEY(mode: AddressingMode) {
        let result = UInt16(registers.y) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
    }

    func opEOR(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)

        registers.a ^= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
    }

    func opINC(mode: AddressingMode) {
        let result = UInt16(registers.a) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.a = UInt8(result & 0xFF)
    }

    func opINX(mode: AddressingMode) {
        let result = UInt16(registers.x) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
    }

    func opINY(mode: AddressingMode) {
        let result = UInt16(registers.y) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
    }

    func opJMP(mode: AddressingMode) {
        let address = addressForAddressingMode(mode)
        setProgramCounter(address)
    }

    func opJSR(mode: AddressingMode) {

    }

    func opLDA(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        registers.a = value
    }

    func opLDX(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        registers.x = value
    }

    func opLDY(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)
        registers.y = value
    }

    func opLSR(mode: AddressingMode) {
        let result:UInt16 = UInt16(registers.a) >> UInt16(1);

        registers.setCarryFlag(registers.a & 0x1 > 0)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        registers.a = UInt8(result & 0xFF)
    }

    func opNOP(mode: AddressingMode) {

    }

    func opORA(mode: AddressingMode) {
        let value = valueForAddressingMode(mode)

        registers.a |= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
    }

    func opPHA(mode: AddressingMode) {
        push8(registers.a)
    }

    func opPHP(mode: AddressingMode) {
        // TODO: Check accuracy of implementation
        push8(registers.getStatusByte())
    }

    func opPLA(mode: AddressingMode) {
        registers.a = pop8()
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
    }

    func opPLP(mode: AddressingMode) {
        // TODO: Check accuracy of implementation
        registers.setStatusByte(pop8())
    }

    func opROL(mode: AddressingMode) {
        let result = UInt16(registers.a) << UInt16(1)

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
    }

    func opROR(mode: AddressingMode) {

    }

    func opRTI(mode: AddressingMode) {

    }

    func opRTS(mode: AddressingMode) {

    }

    func opSBC(mode: AddressingMode) {

    }

    func opSEC(mode: AddressingMode) {

    }

    func opSED(mode: AddressingMode) {

    }

    func opSEI(mode: AddressingMode) {

    }

    func opSTA(mode: AddressingMode) {

    }

    func opSTX(mode: AddressingMode) {

    }

    func opSTY(mode: AddressingMode) {

    }

    func opTAX(mode: AddressingMode) {
        registers.x = registers.a
    }

    func opTAY(mode: AddressingMode) {
        registers.y = registers.a
    }

    func opTSX(mode: AddressingMode) {
        registers.x = registers.s
    }

    func opTXA(mode: AddressingMode) {
        registers.a = registers.x
    }

    func opTXS(mode: AddressingMode) {
        registers.s = registers.x
    }

    func opTYA(mode: AddressingMode) {
        registers.a = registers.y
    }
}