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

    override func setUp() {
        super.setUp()
        cpu = CPU6502()
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

}
