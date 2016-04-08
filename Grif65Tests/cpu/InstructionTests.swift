//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

// Instruction tests based on tests for PY65
// https://github.com/mnaberez/py65

import Foundation
import XCTest
import Nimble

@testable import Grif65


class InstructionTests: XCTestCase {

    var cpu:CPU6502 = CPU6502()
    var mem:[UInt8] = [UInt8]()

    override func setUp() {
        super.setUp()
        cpu = CPU6502()
        mem = [UInt8](count:0xFFFF, repeatedValue:0x0)

        cpu.readMemoryCallback =  { (address:UInt16) -> UInt8 in
            
            return self.mem[Int(address)]
        }

        cpu.writeMemoryCallback =  { (address:UInt16, value:UInt8) in
            self.mem[Int(address)] = value
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    /* ADC Absolute addressing */

    func testADCWithBCDOffAbsoluteCarryClearInAccumulatorZeros() {
        self.cpu.setMem(0xC000, value:0x00)

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0xC000, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0xC000, value:0xFE)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInCarrySetOut() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x02

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x7F

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x80

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetOn80Plus80() {
        self.cpu.setMem(0xC000, value:0x40)
        self.cpu.registers.a = 0x40

        self.cpu.opADC(AddressingMode.Absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Zero Page */

    func testADCWithBCDOffZPCarryClearInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0x00B0, value:0xFE)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInCarrySetOut() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x02

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x7F

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x80

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetOn80Plus80() {
        self.cpu.setMem(0x00B0, value:0x40)
        self.cpu.registers.a = 0x40

        self.cpu.opADC(AddressingMode.ZeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Immediate */

    func testADCWithBCDOffImmediateCarryClearInAccumulatorZeros() {
        self.cpu.opADC(AddressingMode.Immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateCarrySetInAccumulatorZeros() {
        self.cpu.registers.setCarryFlag(true)

        self.cpu.opADC(AddressingMode.Immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInNoCarryClearOut() {
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Immediate(0xFE))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInCarrySetOut() {
        self.cpu.registers.a = 0x02

        self.cpu.opADC(AddressingMode.Immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01Plus01() {
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01PlusFF() {
        self.cpu.registers.a = 0x01

        self.cpu.opADC(AddressingMode.Immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry7FPlus01() {
        self.cpu.registers.a = 0x7F

        self.cpu.opADC(AddressingMode.Immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry80PlusFF() {
        self.cpu.registers.a = 0x80

        self.cpu.opADC(AddressingMode.Immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetOn80Plus80() {
        self.cpu.registers.a = 0x40

        self.cpu.opADC(AddressingMode.Immediate(0x40))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ASL Accumulator */

    func testASLAccumulatorSetsZFlag() {
        self.cpu.registers.a = 0x00

        self.cpu.opASL(AddressingMode.Accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAccumulatorSetsNFlag() {
        self.cpu.registers.a = 0x40

        self.cpu.opASL(AddressingMode.Accumulator)

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAccumulatorShiftsOutZero() {
        self.cpu.registers.a = 0x7F

        self.cpu.opASL(AddressingMode.Accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAccumulatorShiftsOutOne() {
        self.cpu.registers.a = 0xFF

        self.cpu.opASL(AddressingMode.Accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAccumulator80SetsZFlag() {
        self.cpu.registers.a = 0x80

        self.cpu.opASL(AddressingMode.Accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    /* ASL Absolute */

    func testASLAbsoluteSetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x00)

        self.cpu.opASL(AddressingMode.Absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAbsoluteSetsNFlag() {
        self.cpu.setMem(0xABCD, value: 0x40)

        self.cpu.opASL(AddressingMode.Absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAbsoluteShiftsOutZero() {
        self.cpu.setMem(0xABCD, value: 0x7F)

        self.cpu.opASL(AddressingMode.Absolute(0xABCD))
        
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAbsoluteShiftsOutOne() {
        self.cpu.setMem(0xABCD, value: 0xFF)

        self.cpu.opASL(AddressingMode.Absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAbsolute80SetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x80)

        self.cpu.opASL(AddressingMode.Absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* BEQ */
    
    func testBEQZeroSetBranchesRelativeForward() {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x06))
    }
    
    func testBEQZeroSetBranchesRelativeBackward() {
        self.cpu.registers.setZeroFlag(true)
        let rel = (0x06 ^ 0xFF + 1)
        self.cpu.setMem(0x0050, value:0xF0)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16(0x0052 + rel)))
    }
    
    func testBEQZeroClearDoesNotBranch() {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }

    /* JSR */

    func testJSR() {
        self.cpu.setMemFromHexString("20 D2 FF", address:0xC000)
        self.cpu.setProgramCounter(0xC000)
        self.cpu.runCycles(1)

        expect(self.cpu.registers.pc).to(equal(0xFFD2))
        expect(self.cpu.getStackPointer()).to(equal(0xFD))
        expect(self.mem[0x01FF]).to(equal(0xC0))
        expect(self.mem[0x01FE]).to(equal(0x02))
    }
    
    /* RTS */
    
    func testRTS() {
        self.cpu.setMem(0x0000, value: 0x60)
        self.cpu.setMemFromHexString("03 C0", address:0x1FE)
        self.cpu.setProgramCounter(0x0)
        self.cpu.registers.s = 0xFD
        
        self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xC004))
        expect(self.cpu.registers.s).to(equal(0xFF))
    }
}
