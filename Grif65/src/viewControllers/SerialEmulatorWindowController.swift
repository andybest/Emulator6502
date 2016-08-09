//
//  SerialEmulatorWindowController.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Cocoa

class SerialEmulatorWindowController: NSWindowController, NSTextViewDelegate, NSTextDelegate {

    @IBOutlet var serialTextView: GrifConsoleTextView!

    override func windowDidLoad() {
        super.windowDidLoad()

        initSerialTextView()
    }

    func initSerialTextView() {
        
    }

    func processSerialData(_ value: UInt8) {
        if let str = NSString(bytes: [value], length: 1, encoding: String.Encoding.utf8.rawValue) {
            //serialTextView.string! += str as String
        }
    }

//    // MARK - NSTextViewDelegate
//    func textView(_ textView: NSTextView,
//                  willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
//                  toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
//        print(oldSelectedCharRange, newSelectedCharRange)
//        if newSelectedCharRange.length > 0 || newSelectedCharRange.location < textView.string!.characters.count {
//            return oldSelectedCharRange
//        }
//        return newSelectedCharRange
//    }

//    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
////        if affectedCharRange.location != textView.string!.characters.count {
////            return false
////        }
////
////        return true
//        return false
//    }
    


}
