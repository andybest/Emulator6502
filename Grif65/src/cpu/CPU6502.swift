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
    case Accumulator
    case Implicit
    case Immediate(UInt8)
    case ZeroPage(UInt8)
    case ZeroPageX(UInt8)
    case ZeroPageY(UInt8)
    case Relative(UInt8)
    case Absolute(UInt16)
    case AbsoluteX(UInt16)
    case AbsoluteY(UInt16)
    case Indirect(UInt16)
    case IndirectX(UInt16)
    case IndirectY(UInt16)
}

enum InstructionAddressingMode {
    case Implicit
    case Accumulator
    case Immediate
    case ZeroPage
    case ZeroPageX
    case ZeroPageY
    case Relative
    case Absolute
    case AbsoluteX
    case AbsoluteY
    case Indirect
    case IndirectX
    case IndirectY
}

struct InstructionEntry {
    let instructionName:     String
    let instructionFunction: (AddressingMode) -> (Void)
    let addressingMode:      (InstructionAddressingMode)
    let numBytes:            Int
    let numCycles:           Int
    let specialCycles:       Bool

    func prettyDescription() -> String {
        return "\(instructionName), Addressing mode: \(addressingMode), Cycles: \(numCycles)"
    }
}

class CPU6502 {
    var registers: Registers
    var memory           = [UInt8](count: 0xFFFF, repeatedValue: 0x00)
    var instructionTable = [InstructionEntry]()

    init() {
        self.registers = Registers()
        buildInstructionTable()

        setProgramCounter(0x0100)

        // LDA #$01
        setMem(0x0100, value: 0xA9)
        setMem(0x0101, value: 0x01)

        // ADC #$01
        setMem(0x0102, value: 0x69)
        setMem(0x0103, value: 0x01)

        // ADC #$01
        setMem(0x0104, value: 0x69)
        setMem(0x0105, value: 0x01)

        // TAX
        setMem(0x0106, value: 0xAA)

        // ADC #$01
        setMem(0x0107, value: 0x69)
        setMem(0x0108, value: 0x01)

        // TAY
        setMem(0x0109, value: 0xA8)

        // INY
        setMem(0x010A, value: 0xC8)


        print(runCycles(10))
    }

    func reset() {
        self.registers.s = 0xFD

        self.registers.setInterruptFlag(true)
        self.registers.setDecimalFlag(true)
        self.registers.setBreakFlag(true)
    }

    func printCPUState() {
        print("\(registers.stateString())")
    }

    func setMem(address: UInt16, value: UInt8) {
        memory[Int(address)] = value
    }

    func getMem(address: UInt16) -> UInt8 {
        return memory[Int(address)]
    }

    func getZero(address: UInt8) -> UInt8 {
        return getMem(UInt16(address))
    }

    func getProgramCounter() -> UInt16 {
        return registers.pc
    }

    func setProgramCounter(value: UInt16) {
        registers.pc = value
    }

    func getStackPointer() -> UInt8 {
        return registers.s
    }

    func push8(value: UInt8) {
        setMem(UInt16(registers.s), value: value)
        registers.s -= 1
    }

    func pop8() -> UInt8 {
        registers.s += 1
        return getMem(UInt16(registers.s))
    }

    func runCycles(numCycles: Int) -> Int {
        var cycles = 0
        while cycles <= numCycles {
            let opcode = getMem(getProgramCounter())
            cycles += executeOpcode(opcode)
        }

        return cycles
    }

    func getModeForCurrentOpcode(mode: InstructionAddressingMode) -> AddressingMode {
        switch (mode) {
        case .Implicit:
            return AddressingMode.Implicit
        case .Accumulator:
            return AddressingMode.Accumulator
        case .Immediate:
            return AddressingMode.Immediate(getMem(getProgramCounter() + 1))
        case .ZeroPage:
            return AddressingMode.ZeroPage(getMem(getProgramCounter() + 1))
        case .ZeroPageX:
            return AddressingMode.ZeroPageX(getMem(getProgramCounter() + 1))
        case .ZeroPageY:
            return AddressingMode.ZeroPageY(getMem(getProgramCounter() + 1))
        case .Relative:
            return AddressingMode.Relative(getMem(getProgramCounter() + 1))
        case .Absolute:
            return AddressingMode.Absolute(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .AbsoluteX:
            return AddressingMode.AbsoluteX(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .AbsoluteY:
            return AddressingMode.AbsoluteY(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .Indirect:
            return AddressingMode.Indirect(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .IndirectX:
            return AddressingMode.IndirectX(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .IndirectY:
            return AddressingMode.IndirectY(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        }
    }

    func executeOpcode(opcode: UInt8) -> Int {
        let instruction    = instructionTable[Int(opcode)]
        let addressingMode = getModeForCurrentOpcode(instruction.addressingMode)
        let addr           = String(format: "0x%2X", getProgramCounter())
        print("Executing instruction at \(addr): \(instruction.prettyDescription())")
        setProgramCounter(getProgramCounter() + UInt16(instruction.numBytes))
        instruction.instructionFunction(addressingMode)
        printCPUState()

        return instruction.numCycles
    }

}

