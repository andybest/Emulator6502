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
        mem = [UInt8](repeating: 0x0, count: 0xFFFF)

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

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0xC000, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0xC000, value:0xFE)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInCarrySetOut() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetOn80Plus80() {
        self.cpu.setMem(0xC000, value:0x40)
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Zero Page */

    func testADCWithBCDOffZPCarryClearInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0x00B0, value:0xFE)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInCarrySetOut() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetOn80Plus80() {
        self.cpu.setMem(0x00B0, value:0x40)
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Immediate */

    func testADCWithBCDOffImmediateCarryClearInAccumulatorZeros() {
        _ = self.cpu.opADC(AddressingMode.immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateCarrySetInAccumulatorZeros() {
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInNoCarryClearOut() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0xFE))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInCarrySetOut() {
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01Plus01() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01PlusFF() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry7FPlus01() {
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry80PlusFF() {
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetOn80Plus80() {
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.immediate(0x40))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ASL Accumulator */

    func testASLAccumulatorSetsZFlag() {
        self.cpu.registers.a = 0x00

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAccumulatorSetsNFlag() {
        self.cpu.registers.a = 0x40

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAccumulatorShiftsOutZero() {
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAccumulatorShiftsOutOne() {
        self.cpu.registers.a = 0xFF

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAccumulator80SetsZFlag() {
        self.cpu.registers.a = 0x80

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    /* ASL Absolute */

    func testASLAbsoluteSetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x00)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAbsoluteSetsNFlag() {
        self.cpu.setMem(0xABCD, value: 0x40)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAbsoluteShiftsOutZero() {
        self.cpu.setMem(0xABCD, value: 0x7F)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))
        
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAbsoluteShiftsOutOne() {
        self.cpu.setMem(0xABCD, value: 0xFF)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAbsolute80SetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x80)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* AND Absolute */
    
    /* BEQ */
    
    func testBEQZeroSetBranchesRelativeForward() {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x06))
    }
    
    func testBEQZeroSetBranchesRelativeBackward() {
        self.cpu.registers.setZeroFlag(true)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0xF0)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 122).0))
    }
    
    func testBEQZeroClearDoesNotBranch() {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BIT Absolute */
    
    func testBITAbsoluteCopiesBit7OfMemoryToNFlagWhen0() {
        self.cpu.registers.setSignFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    func testBITAbsoluteCopiesBit7OfMemoryToNFlagWhen1() {
        self.cpu.registers.setSignFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testBITAbsoluteCopiesBit6OfMemoryToVFlagWhen0() {
        self.cpu.registers.setOverflowFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }
    
    func testBITAbsoluteCopiesBit6OfMemoryToVFlagWhen1() {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }
    
    func testBITAbsoluteStoresResultOfAndWhenZeroInZPreservesAWhen1()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0xFEED)).to(equal(0x00))
    }
    
    func testBITAbsoluteStoresResultOfAndWhenNonZeroInZPreservesAWhen0()
    {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x01)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0xFEED)).to(equal(0x01))
    }
    
    /* BIT Zero Page */
    
    func testBITZeroPageCopiesBit7OfMemoryToNFlagWhen0()
    {
        self.cpu.registers.setSignFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    func testBITZeroPageCopiesBit7OfMemoryToNFlagWhen1()
    {
        self.cpu.registers.setSignFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testBITZeroPageCopiesBit6OfMemoryToVFlagWhen0()
    {
        self.cpu.registers.setOverflowFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }
    
    func testBITZeroPageCopiesBit6OfMemoryToVFlagWhen1()
    {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }
    
    func testBITZeroPageStoresResultOfAndInZPreservesAWhen1()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
    }

    func testBITZeroPageStoresResultOfAndWhenNonZeroInZPreservesA()
    {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x01)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x01))
    }
    
    func testBITZeroPageStoresResultOfAndWhenZeroInZPreservesA()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
    }

    /* JSR */

    func testJSR() {
        self.cpu.setMemFromHexString("20 D2 FF", address:0xC000)
        self.cpu.setProgramCounter(0xC000)
        _ = self.cpu.runCycles(1)

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
        
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xC004))
        expect(self.cpu.registers.s).to(equal(0xFF))
    }
}
