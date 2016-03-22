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
    case ModeA = 0, StatusA, ClockSelectA, ReceiveBufferA, InputPortChange, InterruptStatus, CounterModeMSB,
         CounterModeLSB, ModeB, StatusB, ClockSelectB, ReceiveBufferB, InterruptVector, InputPort, StartCounterCommend,
         StopCounterCommand
}

enum DUARTWriteRegisters: UInt8 {
    case ModeA = 0, ClockSelectA, CommandA, TransmitBufferA, AuxilaryControl, InterruptMask, CounterTimerUpper,
         CounterTimerLower, ModeB, ClockSelectB, CommandB, TransmitBufferB, InterruptVector, OutputPortConfiguration,
         BitSetCommand, BitResetCommand
}

enum DUARTSerialChannel {
    case SerialChannelA
    case SerialChannelB
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

    mutating func setByte(value: UInt8) {
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
    var serialChannelSend: ((value:UInt8, channel:DUARTSerialChannel) -> (Void))?

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
    func attachInterruptHandler(handler: (Void) -> (Void)) {
        assertInterrupt = handler
    }

    func attachSerialChannelSendCallback(callback: (value:UInt8, channel:DUARTSerialChannel) -> (Void)) {
        serialChannelSend = callback
    }

    // MARK - Register read/write

    func readMemory(address: UInt8) -> UInt8 {
        if address == DUARTReadRegisters.ReceiveBufferA.rawValue || address == DUARTReadRegisters.ReceiveBufferB.rawValue {
            let channel = address == DUARTReadRegisters.ReceiveBufferA.rawValue ? DUARTSerialChannel.SerialChannelA : DUARTSerialChannel.SerialChannelB

        }

        return 0
    }

    func writeMemory(address: UInt8, value: UInt8) {
        if address == 0x3 {
            serialChannelTransmit(value, channel:DUARTSerialChannel.SerialChannelA)
        }
    }

    // MARK - Serial Communications

    func serialChannelReceive(value: UInt8, channel: DUARTSerialChannel) {
        var receiveBuffer:  [UInt8]
        var statusRegister: DUARTStatusRegister

        switch channel {
        case .SerialChannelA:
            receiveBuffer = receiveBufferA
            statusRegister = statusRegisterA
            break
        case .SerialChannelB:
            receiveBuffer = receiveBufferB
            statusRegister = statusRegisterB
            break
        }

        // The 68681 has a 3 byte FIFO for each channel and can hold an extra byte in the input shift register.
        // If the input shift register already holds a byte, the next one will overwrite it and cause the
        // overrun-error status bit to be set for that channel.

        if receiveBuffer.count > 3 {
            // Set overrun flag
            statusRegister.overrunError = true

            // Emulate the shift register value being overwritten
            receiveBuffer[3] = value
        } else {
            receiveBuffer.append(value)
        }
    }

    func serialChannelTransmit(value: UInt8, channel: DUARTSerialChannel) {
        if let cb = self.serialChannelSend {
            cb(value: value, channel: channel)
        }

    }
}
