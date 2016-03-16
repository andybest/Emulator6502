//
//  GrifEmulator.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Foundation

class GrifEmulator {
    
    var cpu: CPU6502
    var ram: [UInt8]
    
    init() {
        cpu = CPU6502()
        ram = [UInt8](count: 0xFFFF, repeatedValue: 0)
    }
    
    func getMemory(address:UInt8) {
        
    }
    
}