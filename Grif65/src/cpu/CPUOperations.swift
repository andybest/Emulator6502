//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation


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

    func getIndirect(address: UInt16) -> UInt8 {
        let indirectAddress: UInt16 = address
        return getMem(indirectAddress | ((indirectAddress + 1) << 8))
    }

    func getIndirectX(address: UInt16) -> UInt8 {
        return getIndirect(address + UInt16(registers.x))
    }

    func getIndirectY(address: UInt16) -> UInt8 {
        let indirectAddress: UInt16 = address + UInt16(registers.y)
        return getMem(indirectAddress | ((indirectAddress + 1) << 8))
    }

    func valueForAddressingMode(mode: AddressingMode) -> UInt8 {
        switch mode {
        case .Accumulator:
            return registers.a
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
        case .Relative(let val):
            return UInt16(val)
        default: // This should raise an exception
            return 0
        }
    }

    func setValueForAddressingMode(value: UInt8, mode: AddressingMode) {
        switch mode {
        case .Accumulator:
            registers.a = value;
            break
        default:
            let addr = addressForAddressingMode(mode)
            setMem(addr, value: value)
            break
        }
    }

    func defaultResponse() -> InstructionResponse {
        return InstructionResponse(handlesPC: false)
    }

    func opADC(mode: AddressingMode) -> InstructionResponse {
        let value          = valueForAddressingMode(mode)

        // Add the value to accumulator, add 1 if carry flag is active
        let result: UInt16 = UInt16(registers.a) +
                UInt16(value) +
                UInt16(registers.boolToInt(registers.getCarryFlag()))

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setOverflowFlag(calculateOverflow(result, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(result))

        registers.a = UInt8(result & UInt16(0xFF))

        return defaultResponse()
    }

    func opAND(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a &= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))

        return defaultResponse()
    }

    func opASL(mode: AddressingMode) -> InstructionResponse {
        let value          = valueForAddressingMode(mode)
        let result: UInt16 = UInt16(value) << UInt16(1)

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)

        return defaultResponse()
    }

    func opBCC(mode: AddressingMode) -> InstructionResponse {
        if !registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBCS(mode: AddressingMode) -> InstructionResponse {
        if registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBEQ(mode: AddressingMode) -> InstructionResponse {
        if registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBIT(mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
        let result = UInt16(registers.a) & UInt16(value)

        registers.setZeroFlag(calculateZero(result))
        registers.setOverflowFlag(calculateOverflow(result, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(result))
        return defaultResponse()
    }

    func opBMI(mode: AddressingMode) -> InstructionResponse {
        if registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBNE(mode: AddressingMode) -> InstructionResponse {
        if !registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBPL(mode: AddressingMode) -> InstructionResponse {
        if !registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBRK(mode: AddressingMode) -> InstructionResponse {
        setProgramCounter(getProgramCounter() + 1)
        push16(getProgramCounter())
        push8(registers.getStatusByte())
        registers.setInterruptFlag(true)
        setProgramCounter(UInt16(getMem(0xFFFE)) | (UInt16(0xFFFF) << 8))

        breakExecuted()
        return InstructionResponse(handlesPC: true)
    }

    func opBVC(mode: AddressingMode) -> InstructionResponse {
        if !registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBVS(mode: AddressingMode) -> InstructionResponse {
        if registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            setProgramCounter(getProgramCounter() + relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opCLC(mode: AddressingMode) -> InstructionResponse {
        registers.setCarryFlag(false)
        return defaultResponse()
    }

    func opCLD(mode: AddressingMode) -> InstructionResponse {
        registers.setDecimalFlag(false)
        return defaultResponse()
    }

    func opCLI(mode: AddressingMode) -> InstructionResponse {
        registers.setInterruptFlag(false)
        return defaultResponse()
    }

    func opCLV(mode: AddressingMode) -> InstructionResponse {
        registers.setOverflowFlag(false)
        return defaultResponse()
    }

    func opCMP(mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
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
        return defaultResponse()
    }

    func opCPX(mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
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
        return defaultResponse()
    }

    func opCPY(mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
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
        return defaultResponse()
    }

    func opDEC(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.a) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.a = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opDEX(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.x) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opDEY(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.y) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opEOR(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a ^= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opINC(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        let result = value + 1
        registers.setZeroFlag(calculateZero(UInt16(result)))
        registers.setSignFlag(calculateSign(UInt16(result)))
        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opINX(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.x) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opINY(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.y) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opJMP(mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setProgramCounter(address)
        return InstructionResponse(handlesPC: true)
    }

    func opJSR(mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        push16(getProgramCounter())
        setProgramCounter(address)
        return InstructionResponse(handlesPC: true)
    }

    func opLDA(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.a = value
        return defaultResponse()
    }

    func opLDX(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.x = value
        return defaultResponse()
    }

    func opLDY(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.y = value
        return defaultResponse()
    }

    func opLSR(mode: AddressingMode) -> InstructionResponse {
        let result: UInt16 = UInt16(valueForAddressingMode(mode)) >> UInt16(1);

        registers.setCarryFlag(registers.a & 0x1 > 0)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opNOP(mode: AddressingMode) -> InstructionResponse {
        return defaultResponse()
    }

    func opORA(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a |= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opPHA(mode: AddressingMode) -> InstructionResponse {
        push8(registers.a)
        return defaultResponse()
    }

    func opPHP(mode: AddressingMode) -> InstructionResponse {
        push8(registers.getStatusByte())
        return defaultResponse()
    }

    func opPLA(mode: AddressingMode) -> InstructionResponse {
        registers.a = pop8()
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opPLP(mode: AddressingMode) -> InstructionResponse {
        registers.setStatusByte(pop8())
        return defaultResponse()
    }

    func opROL(mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(valueForAddressingMode(mode)) << UInt16(1)

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result), mode: mode)
        return defaultResponse()
    }

    func opROR(mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        let bit    = value & 0x01
        let result = UInt16(value) >> UInt16(1)

        registers.setCarryFlag(bit > 0)
        registers.setZeroFlag((calculateZero(result)))
        registers.setSignFlag((calculateSign(result)))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opRTI(mode: AddressingMode) -> InstructionResponse {
        registers.setStatusByte(pop8())
        setProgramCounter(pop16())
        return InstructionResponse(handlesPC: true)
    }

    func opRTS(mode: AddressingMode) -> InstructionResponse {
        let returnAddress = pop16()
        setProgramCounter(returnAddress)
        return InstructionResponse(handlesPC: true)
    }

    func opSBC(mode: AddressingMode) -> InstructionResponse {
        return defaultResponse()
    }

    func opSEC(mode: AddressingMode) -> InstructionResponse {
        registers.setCarryFlag(true)
        return defaultResponse()
    }

    func opSED(mode: AddressingMode) -> InstructionResponse {
        registers.setDecimalFlag(true)
        return defaultResponse()
    }

    func opSEI(mode: AddressingMode) -> InstructionResponse {
        registers.setInterruptFlag(true)
        return defaultResponse()
    }

    func opSTA(mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.a)
        return defaultResponse()
    }

    func opSTX(mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.x)
        return defaultResponse()
    }

    func opSTY(mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.y)
        return defaultResponse()
    }

    func opTAX(mode: AddressingMode) -> InstructionResponse {
        registers.x = registers.a
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTAY(mode: AddressingMode) -> InstructionResponse {
        registers.y = registers.a
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTSX(mode: AddressingMode) -> InstructionResponse {
        registers.x = registers.s
        registers.setSignFlag(calculateSign(UInt16(registers.s)))
        registers.setZeroFlag(calculateSign(UInt16(registers.s)))
        return defaultResponse()
    }

    func opTXA(mode: AddressingMode) -> InstructionResponse {
        registers.a = registers.x
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTXS(mode: AddressingMode) -> InstructionResponse {
        registers.s = registers.x
        registers.setSignFlag(calculateSign(UInt16(registers.s)))
        registers.setZeroFlag(calculateSign(UInt16(registers.s)))
        return defaultResponse()
    }

    func opTYA(mode: AddressingMode) -> InstructionResponse {
        registers.a = registers.y
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }
}