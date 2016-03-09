//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import Grif65


class CPUTests: XCTestCase {

    var cpu:CPU6502 = CPU6502()

    override func setUp() {
        super.setUp()
        cpu = CPU6502()
    }

    override func tearDown() {
        super.tearDown()
    }

}
