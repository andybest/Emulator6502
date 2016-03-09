//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

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

}
