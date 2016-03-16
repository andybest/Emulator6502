//
//  SerialEmulatorWindowController.swift
//  Grif65
//
//  Created by Andy Best on 16/03/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Cocoa

class SerialEmulatorWindowController: NSWindowController, NSTextViewDelegate, NSTextDelegate {

    @IBOutlet var serialTextView: NSTextView!

    override func windowDidLoad() {
        super.windowDidLoad()

        initSerialTextView()
    }

    func initSerialTextView() {
        serialTextView.delegate = self
        serialTextView.font = NSFont(name: "Menlo", size:12.0)
        serialTextView.backgroundColor = NSColor.blackColor()
        serialTextView.textColor = NSColor.greenColor()
        serialTextView.insertionPointColor = NSColor.whiteColor()
    }

    // MARK - NSTextViewDelegate
    func textView(textView: NSTextView,
                  willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
                  toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
        print(oldSelectedCharRange, newSelectedCharRange)
        if newSelectedCharRange.length > 0 || newSelectedCharRange.location < textView.string!.characters.count {
            return oldSelectedCharRange
        }
        return newSelectedCharRange
    }
    
    func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String?) -> Bool {
        if affectedCharRange.location != textView.string!.characters.count {
            return false
        }

        return true
    }

    // MARK - NSTextDelegate

}
