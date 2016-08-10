//
// Created by Andy Best on 17/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//
// An implementation of the Motorola 68681 DUART

import Foundation

extension Bool {
    func asUint8() -> UInt8 {
        return self ? 1 : 0
    }
}

enum DUARTReadRegisters: UInt8 {
    case modeA = 0, statusA, clockSelectA, receiveBufferA, inputPortChange, interruptStatus, counterModeMSB,
         counterModeLSB, modeB, statusB, clockSelectB, receiveBufferB, interruptVector, inputPort, startCounterCommend,
         stopCounterCommand
}

enum DUARTWriteRegisters: UInt8 {
    case modeA = 0, clockSelectA, commandA, transmitBufferA, auxilaryControl, interruptMask, counterTimerUpper,
         counterTimerLower, modeB, clockSelectB, commandB, transmitBufferB, interruptVector, outputPortConfiguration,
         bitSetCommand, bitResetCommand
}

enum DUARTSerialChannel {
    case serialChannelA
    case serialChannelB
}

struct DUARTStatusRegister {
    var receivedBreak:    Bool
    var framingError:     Bool
    var parityError:      Bool
    var overrunError:     Bool
    var transmitterEmpty: Bool
    var transmitterReady: Bool
    var fifoFull:         Bool
    var receiverReady:    Bool

    init() {
        receivedBreak = false
        framingError = false
        parityError = false
        overrunError = false
        transmitterEmpty = false
        transmitterReady = false
        fifoFull = false
        receiverReady = false
    }

    func getByte() -> UInt8 {
        return receivedBreak.asUint8() << 7 |
                framingError.asUint8() << 6 |
                parityError.asUint8() << 5 |
                overrunError.asUint8() << 4 |
                transmitterEmpty.asUint8() << 3 |
                transmitterReady.asUint8() << 2 |
                fifoFull.asUint8() << 1 |
                receiverReady.asUint8()
    }

    mutating func setByte(_ value: UInt8) {
        receivedBreak = ((value & 0b10000000) >> 7) > 0
        framingError = ((value & 0b01000000) >> 6) > 0
        parityError = ((value & 0b00100000) >> 5) > 0
        overrunError = ((value & 0b00010000) >> 4) > 0
        transmitterEmpty = ((value & 0b00001000) >> 3) > 0
        transmitterReady = ((value & 0b00000100) >> 2) > 0
        fifoFull = ((value & 0b00000010) >> 1) > 0
        receiverReady = (value & 0b00000001) > 0
    }
}

class DUART: IODevice {

    var assertInterrupt:   ((Void) -> (Void))?
    var serialChannelSend: ((UInt8, DUARTSerialChannel) -> (Void))?

    var receiveBufferA = [UInt8]()
    var receiveBufferB = [UInt8]()

    var sendBufferA = [UInt8]()
    var sendBufferB = [UInt8]()

    var statusRegisterA = DUARTStatusRegister()
    var statusRegisterB = DUARTStatusRegister()

    init() {
        statusRegisterA.setByte(0)
        statusRegisterB.setByte(0)
    }

    // MARK - Callbacks
    func attachInterruptHandler(_ handler: (Void) -> (Void)) {
        assertInterrupt = handler
    }

    func attachSerialChannelSendCallback(callback: (value:UInt8, channel:DUARTSerialChannel) -> (Void)) {
        serialChannelSend = callback
    }

    // MARK - Register read/write

    func readMemory(_ address: UInt8) -> UInt8 {
        
        // Status register
        if address == DUARTReadRegisters.statusA.rawValue || address == DUARTReadRegisters.statusB.rawValue {
            let channel = address == DUARTReadRegisters.statusA.rawValue ? DUARTSerialChannel.serialChannelA : DUARTSerialChannel.serialChannelB
            switch(channel) {
            case .serialChannelA:
                return statusRegisterA.getByte()
            case .serialChannelB:
                return statusRegisterB.getByte()
            }
        }
        
        // Receive buffer
        if address == DUARTReadRegisters.receiveBufferA.rawValue || address == DUARTReadRegisters.receiveBufferB.rawValue {
            let channel = address == DUARTReadRegisters.receiveBufferA.rawValue ? DUARTSerialChannel.serialChannelA : DUARTSerialChannel.serialChannelB
            return self.readByte(channel)
        }

        return 0
    }

    func writeMemory(_ address: UInt8, value: UInt8) {
        if address == 0x3 {
            serialChannelTransmit(value, channel:DUARTSerialChannel.serialChannelA)
        }
    }
    
    func readByte(_ channel: DUARTSerialChannel) -> UInt8 {
        
        switch channel {
        case .serialChannelA:
            if receiveBufferA.count == 0 {
                return 0
            }
            
            if receiveBufferA.count == 1 {
                statusRegisterA.receiverReady = false
            }
            
            return receiveBufferA.removeFirst()
            
        case .serialChannelB:
            if receiveBufferB.count == 0 {
                return 0
            }
            
            if receiveBufferB.count == 1 {
                statusRegisterB.receiverReady = false
            }
            
            return receiveBufferB.removeFirst()
        }
    }

    // MARK - Serial Communications

    func serialChannelReceive(_ value: UInt8, channel: DUARTSerialChannel) {
        switch channel {
        case .serialChannelA:
            // The 68681 has a 3 byte FIFO for each channel and can hold an extra byte in the input shift register.
            // If the input shift register already holds a byte, the next one will overwrite it and cause the
            // overrun-error status bit to be set for that channel.
            
            statusRegisterA.receiverReady = true
            
            if receiveBufferA.count > 3 {
                // Set overrun flag
                statusRegisterA.overrunError = true
                
                // Emulate the shift register value being overwritten
                receiveBufferA[3] = value
            } else {
                receiveBufferA.append(value)
            }
            
        case .serialChannelB:
            // The 68681 has a 3 byte FIFO for each channel and can hold an extra byte in the input shift register.
            // If the input shift register already holds a byte, the next one will overwrite it and cause the
            // overrun-error status bit to be set for that channel.
            
            statusRegisterB.receiverReady = true
            
            if receiveBufferB.count > 3 {
                // Set overrun flag
                statusRegisterB.overrunError = true
                
                // Emulate the shift register value being overwritten
                receiveBufferB[3] = value
            } else {
                receiveBufferB.append(value)
            }
        }
    }

    func serialChannelTransmit(_ value: UInt8, channel: DUARTSerialChannel) {
        if let cb = self.serialChannelSend {
            cb(value, channel)
        }

    }
}
