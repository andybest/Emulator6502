//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

enum RegisterDef {
    case ARegister
    case XRegister
    case YRegister

    case StatusRegister
    case StackRegister
    case PCRegister
}

enum AddressingMode {
    case Immediate(UInt8)
    case ZeroPage(UInt8)
    case ZeroPageX(UInt8)
    case Absolute(UInt16)
    case AbsoluteX(UInt16)
    case AbsoluteY(UInt16)
    case Indirect(UInt8)
    case IndirectX(UInt8)
    case IndirectY(UInt8)
}

class CPU6502 {
    var registers: Registers

    init() {
        self.registers = Registers()
    }

    func reset() {
        self.registers.s = 0xFD

        self.registers.setInterruptFlag(true)
        self.registers.setDecimalFlag(true)
        self.registers.setBreakFlag(true)
    }

    func getMem(address:UInt16) -> UInt8 {
        return 0
    }

    func getZero(address:UInt8) -> UInt8 {
        return getMem(UInt16(address))
    }

}

extension CPU6502 {

    func getProgramCounter() -> UInt16 {
        return registers.pc
    }

    func setProgramCounter(value: UInt16) {
        registers.pc = value
    }

    func getStackPointer() -> UInt8 {
        return registers.s
    }

}

