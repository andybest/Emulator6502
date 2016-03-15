//
// Created by Andy Best on 15/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

class Disassembler {
    var cpu = CPU6502()

    func test() {
        let input = "a9 01 8d 00 02 a9 05 8d 01 02 a9 08 8d 02 02"
        let bytes = input.uint8ArrayFromHexadecimalString()

        
    }
}
