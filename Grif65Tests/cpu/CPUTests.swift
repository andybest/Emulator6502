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

    func testCPUResetState() {
        self.cpu.reset()

        expect(self.cpu.getStackPointer()).to(equal(0xFD))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.y).to(equal(0x00))

        expect(self.cpu.registers.getInterruptFlag()).to(beTrue())
        expect(self.cpu.registers.getBreakFlag()).to(beTrue())
        expect(self.cpu.registers.getDecimalFlag()).to(beTrue())
    }

}
