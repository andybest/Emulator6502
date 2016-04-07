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

    func assemblyString() -> String {
        switch self {
        case Accumulator:
            return "A"
        case Implicit:
            return ""
        case Immediate(let val):
            let str = String(format: "%02X", val)
            return "#$\(str)"
        case ZeroPage(let val):
            let str = String(format: "%02X", val)
            return "$\(str)"
        case ZeroPageX(let val):
            let str = String(format: "%02X", val)
            return "$\(str),X"
        case ZeroPageY(let val):
            let str = String(format: "%02X", val)
            return "$\(str),Y"
        case Relative(let val):
            let str = String(format: "%02X", val)
            return "|$\(str)"
        case Absolute(let val):
            let str = String(format: "%04X", val)
            return "$\(str)"
        case AbsoluteX(let val):
            let str = String(format: "%04X", val)
            return "$\(str),X"
        case AbsoluteY(let val):
            let str = String(format: "%04X", val)
            return "$\(str),Y"
        case Indirect(let val):
            let str = String(format: "%04X", val)
            return "($\(str))"
        case IndirectX(let val):
            let str = String(format: "%04X", val)
            return "($\(str)),X"
        case IndirectY(let val):
            let str = String(format: "%04X", val)
            return "($\(str)),Y"

        }
    }
}

enum AddressingModeRef {
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
    let instructionFunction: (AddressingMode) -> (InstructionResponse)
    let addressingMode:      (AddressingModeRef)
    let numBytes:            Int
    let numCycles:           Int
    let specialCycles:       Bool

    func prettyDescription() -> String {
        return "\(instructionName), Addressing mode: \(addressingMode), Cycles: \(numCycles)"
    }
}

struct InstructionResponse {
    let handlesPC: Bool
}

struct IntelHexRecord {
    let byteCount: UInt8
    let address: UInt16
    let recordType: UInt8
    let data: [UInt8]
    let checksum: UInt8
}

class CPU6502 {
    var registers: Registers
    var memory           = [UInt8](count: 0xFFFF, repeatedValue: 0x00)
    var instructionTable = [InstructionEntry]()

    var readMemoryCallback: ((UInt16) -> (UInt8))?
    var writeMemoryCallback: ((UInt16, UInt8) -> (Void))?

    init() {
        self.registers = Registers()
        buildInstructionTable()
        self.reset()
    }

    func reset() {
        self.registers.s = 0xFF

        self.registers.setInterruptFlag(true)
        self.registers.setDecimalFlag(true)
        self.registers.setBreakFlag(true)
    }

    func printCPUState() {
        print("\(registers.stateString())")
    }

    func setMem(address: UInt16, value: UInt8) {
        guard let cb = self.writeMemoryCallback else {
            print("Error, need to set write memory callback!")
            return
        }

        cb(address, value)
    }

    func getMem(address: UInt16) -> UInt8 {
        guard let cb = self.readMemoryCallback else {
            print("Error, neet to set read memory callback!")
            return 0
        }

        return cb(address)
    }

    func setMemFromHexString(str:String, address:UInt16) {
        let data = str.uint8ArrayFromHexadecimalString()

        var currentAddress = address
        for byte in data {
            setMem(currentAddress, value: byte)
            currentAddress++
        }
    }

    func loadHexFileToMemory(path:String) {
        do {
            var file = try String(contentsOfFile: path, encoding:NSASCIIStringEncoding)
            let lines = file.stringByReplacingOccurrencesOfString("\r", withString: "").componentsSeparatedByString("\n")

            for line in lines {
                let strippedLine = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if !strippedLine.hasPrefix(":") && strippedLine.characters.count > 0 {
                    print("Error, not valid Intel Hex format.")
                    return
                }

                
            }



        } catch {
            print("Unable to load file: \(path)")
            return
        }
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
        setMem(UInt16(registers.s) + 0x0100, value: value)
        registers.s = registers.s &- 1
    }

    func push16(value: UInt16) {
        push8(UInt8((value >> 8) & 0xFF))
        push8(UInt8(value & 0xFF))
    }

    func pop8() -> UInt8 {
        registers.s = registers.s &+ 1
        return getMem(UInt16(registers.s) + 0x0100)
    }

    func pop16() -> UInt16 {
        return UInt16(pop8()) | (UInt16(pop8()) << 8)
    }

    func runCycles(numCycles: Int) -> Int {
        var cycles = 0
        while cycles < numCycles {
            let opcode = getMem(getProgramCounter())
            cycles += executeOpcode(opcode)
        }

        return cycles
    }

    func getModeForCurrentOpcode(mode: AddressingModeRef) -> AddressingMode {
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
            return AddressingMode.Indirect(UInt16(getMem(getProgramCounter() + 1)))
        case .IndirectX:
            return AddressingMode.IndirectX(UInt16(getMem(getProgramCounter() + 1)))
        case .IndirectY:
            return AddressingMode.IndirectY(UInt16(getMem(getProgramCounter() + 1)))
        }
    }

    func executeOpcode(opcode: UInt8) -> Int {
        let instruction    = instructionTable[Int(opcode)]
        let addressingMode = getModeForCurrentOpcode(instruction.addressingMode)
        let addr           = String(format: "0x%2X", getProgramCounter())

        setProgramCounter(getProgramCounter() + UInt16(instruction.numBytes))
        let response = instruction.instructionFunction(addressingMode)

        /*if !response.handlesPC {
            setProgramCounter(getProgramCounter() + UInt16(instruction.numBytes))
        }*/

        print("Executing instruction at \(addr): \(instruction.instructionName) \(addressingMode.assemblyString())")
        printCPUState()
        return instruction.numCycles
    }

    func breakExecuted() {
        print("Break executed at address \(self.registers.pc)")
    }

}

