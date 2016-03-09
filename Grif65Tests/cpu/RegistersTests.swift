//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import Grif65

class RegistersTests: XCTestCase {

    var registers:Registers = Registers()

    override func setUp() {
        super.setUp()
        registers = Registers()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Mark - Status Register

    func testStatusRegisterDefaultState() {
        // Test default state
        expect(self.registers.p).to(equal(0b00100000))
    }

    func testStatusRegisterCarryFlag() {
        expect(self.registers.getCarryFlag()).to(equal(false))

        self.registers.setCarryFlag(true)

        expect(self.registers.p).to(equal(0b00100001))
        expect(self.registers.getCarryFlag()).to(beTrue())
    }

    func testStatusRegisterZeroFlag() {
        expect(self.registers.getZeroFlag()).to(equal(false))

        self.registers.setZeroFlag(true)

        expect(self.registers.p).to(equal(0b00100010))
        expect(self.registers.getZeroFlag()).to(beTrue())
    }

    func testStatusRegisterInterruptFlag() {
        expect(self.registers.getInterruptFlag()).to(equal(false))

        self.registers.setInterruptFlag(true)

        expect(self.registers.p).to(equal(0b00100100))
        expect(self.registers.getInterruptFlag()).to(beTrue())
    }

    func testStatusRegisterDecimalFlag() {
        expect(self.registers.getDecimalFlag()).to(equal(false))

        self.registers.setDecimalFlag(true)

        expect(self.registers.p).to(equal(0b00101000))
        expect(self.registers.getDecimalFlag()).to(beTrue())
    }

    func testStatusRegisterBreakFlag() {
        expect(self.registers.getBreakFlag()).to(equal(false))

        self.registers.setBreakFlag(true)

        expect(self.registers.p).to(equal(0b00110000))
        expect(self.registers.getBreakFlag()).to(beTrue())
    }

    func testStatusRegisterOverflowFlag() {
        expect(self.registers.getOverflowFlag()).to(equal(false))

        self.registers.setOverflowFlag(true)

        expect(self.registers.p).to(equal(0b01100000))
        expect(self.registers.getOverflowFlag()).to(beTrue())
    }

    func testStatusRegisterSignFlag() {
        expect(self.registers.getSignFlag()).to(equal(false))

        self.registers.setSignFlag(true)

        expect(self.registers.p).to(equal(0b10100000))
        expect(self.registers.getSignFlag()).to(beTrue())
    }

}
