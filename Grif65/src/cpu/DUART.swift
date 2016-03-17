//
// Created by Andy Best on 17/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//
// An implementation of the Motorola 68681 DUART

import Foundation

enum DUARTReadRegisters: Int {
    case ModeA = 0, StatusA, ClockSelectA, ReceiveBufferA, InputPortChange, InterruptStatus, CounterModeMSB,
         CounterModeLSB, ModeB, StatusB, ClockSelectB, ReceiveBufferB, InterruptVector, InputPort, StartCounterCommend,
         StopCounterCommand
}

enum DUARTWriteRegisters: Int {
    case ModeA = 0, ClockSelectA, CommandA, TransmitBufferA, AuxilaryControl, InterruptMask, CounterTimerUpper,
         CounterTimerLower, ModeB, ClockSelectB, CommandB, TransmitBufferB, InterruptVector, OutputPortConfiguration,
         BitSetCommand, BitResetCommand
}

class DUART: IODevice {

    func readMemory(address: UInt8) {

    }

    func writeMemory(address: UInt8, value: UInt8) {

    }

}
