//
//  GrifConsoleTextView.swift
//  Grif65
//
//  Created by Andy Best on 09/08/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Cocoa

protocol GrifConsoleDelegate {
    func consoleDidSendSerial(_ value: UInt8)
}


class GrifConsoleTextView: NSView {
    var delegate: GrifConsoleDelegate?
    
    override var acceptsFirstResponder: Bool { return true }
    
    var rawLineBuffer = [String]()
    var screenLineBuffer = [String]()
    var termSize = NSSize()
    
    var cursorBlinkTimer: Timer?
    
    var cursorOn = true
    
    var font = NSFont(name: "Menlo", size: 12)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.recalculateTerminalSize()
        self.setNeedsDisplay(self.bounds)
        
        self.cursorBlinkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GrifConsoleTextView.cursorTimerFired), userInfo: nil, repeats: true)
    }
    
    func cursorTimerFired() {
        self.cursorOn = !self.cursorOn
        self.setNeedsDisplay(self.bounds)
    }
    
    // MARK - Geometry
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        
        recalculateTerminalSize()
    }
    
    func recalculateTerminalSize() {
        let charSize = self.characterSize()
        
        self.termSize = NSSize(width: Int(self.bounds.size.width / charSize.width),
                               height: Int(self.bounds.size.height / charSize.height))
        
        recalculateLineBuffer()
    }
    
    func characterSize() -> NSSize {
        let testChar = "A" as NSString
        return testChar.size(withAttributes: self.textAttributes())
    }
    
    func terminalSize() -> NSSize {
        return self.termSize
    }
    
    // MARK - Line buffer
    
    func recalculateLineBuffer() {
        screenLineBuffer.removeAll()
        
        let tSize = terminalSize()
        
        if tSize.width == 0 || tSize.height == 0 {
            return
        }
        
        for line in rawLineBuffer {
            if line.characters.count < Int(tSize.width) {
                screenLineBuffer.append(line)
            } else {
                // Split the lines up into lines equal to the width of the screen
                var idx = line.startIndex
                
                while idx < line.endIndex {
                    var lineEndIdx: String.Index
                    
                    if line.distance(from: idx, to: line.endIndex) < Int(tSize.width)
                    {
                        lineEndIdx = line.endIndex
                    } else {
                        lineEndIdx = line.index(idx, offsetBy: Int(tSize.width))
                    }
                    
                    let substring = line.substring(with: idx..<lineEndIdx)
                    screenLineBuffer.append(substring)
                    
                    idx = lineEndIdx
                }
            }
        }
        
        self.setNeedsDisplay(self.bounds)
    }
    
    // MARK - Font
    
    func textAttributes() -> [String: AnyObject] {
        return  [
            NSFontAttributeName : self.font!,
            NSForegroundColorAttributeName : NSColor.white
        ]
    }
    
    // MARK - View drawing
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        NSRectFill(self.bounds)
        
        let fontAttributes = self.textAttributes()
        
        // Calculate where the first line should be drawn
        let charSize = self.characterSize()
        
        var textBottom = CGPoint(x: 0, y: 0)
        var cursorLocation: CGPoint
        
        let textHeight = CGFloat(self.screenLineBuffer.count) * charSize.height
        if textHeight < self.bounds.height {
            textBottom = CGPoint(x: 0, y: self.bounds.height - textHeight - charSize.height)
        }
        
        // Add an extra line for the cursor if needed
        if self.screenLineBuffer.count == 0 || self.screenLineBuffer.last!.characters.count >= Int(self.terminalSize().width) {
            if textHeight >= self.bounds.height {
                textBottom.y += charSize.height
            }
            cursorLocation = CGPoint(x: 0, y: textBottom.y - charSize.height)
        } else {
            cursorLocation = textBottom
            
            let lineSize = self.screenLineBuffer.last!.size(withAttributes: fontAttributes)
            cursorLocation.x = lineSize.width
        }
        
        // Draw from the bottom up
        for l in self.screenLineBuffer.reversed() {
            let line = l as NSString
            let lineSize = line.size(withAttributes: fontAttributes)
            
            let coords = CGPoint(x: textBottom.x, y: textBottom.y + lineSize.height)
            
            // Only draw if the line intersects the dirty rect.
            if NSIntersectsRect(dirtyRect, NSMakeRect(coords.x, coords.y, lineSize.width, lineSize.height)) {
                line.draw(at: coords, withAttributes: fontAttributes)
            }
            
            textBottom = coords
            if textBottom.y > self.bounds.size.height {
                break
            }
        }
        
        if cursorOn {
            self.drawCursor(cursorLocation)
        }
        
        super.draw(dirtyRect)
    }
    
    func drawCursor(_ point: CGPoint) {
        NSColor.white.setFill()
        
        let charSize = self.characterSize()
        let rect = CGRect(x: point.x, y: point.y + charSize.height, width: charSize.width, height: charSize.height)
        NSRectFill(rect)
    }
    
    
    // MARK - Keyboard events
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
        
        let modFlag = event.modifierFlags
        let keyString = event.characters
        
        Swift.print((keyString, modFlag))
    }
    
    override func insertText(_ insertString: Any) {
        self.sendString(insertString as! String)
    }
    
    override func moveUp(_ sender: Any?) {
    }
    
    override func moveLeft(_ sender: Any?) {
    }
    
    override func deleteBackward(_ sender: Any?) {
        self.sendBackspace()
    }
    
    override func insertNewline(_ sender: Any?) {
        self.sendNewLine()
    }
    
    // MARK - Process Data
    
    func sendNewLine() {
        self.sendData(0xA)
    }
    
    func sendBackspace() {
        self.sendData(0x8)
    }
    
    func sendString(_ str: String) {
        /*var bytes = [UInt8]()
        let length = UnsafeMutablePointer<Int>(nil)
        let remaining = UnsafeMutablePointer<Range<String.Index>>(nil)
        
        _ = str.getBytes(&bytes, maxLength: 999, usedLength: length!, encoding: String.Encoding.ascii,
                     range: str.startIndex..<str.endIndex, remaining: remaining!)*/
        
        for byte in [UInt8](str.utf8) {
            self.sendData(byte)
        }
    }
    
    func sendData(_ data: UInt8) {
        if self.delegate != nil {
            self.delegate!.consoleDidSendSerial(data)
        }
    }
    
    
    func appendText(_ str:String) {
        if self.rawLineBuffer.count > 0 {
            self.rawLineBuffer[self.rawLineBuffer.count - 1] += str
        } else {
            self.rawLineBuffer.append(str)
        }
        
        recalculateLineBuffer()
    }
    
    func appendNewLine() {
        self.rawLineBuffer.append("")
        self.recalculateLineBuffer()
    }
    
    func deleteCharacter() {
        if self.rawLineBuffer.count > 0 {
            if self.rawLineBuffer.last!.characters.count > 0 {
                self.rawLineBuffer[self.rawLineBuffer.count - 1].remove(at: self.rawLineBuffer.last!.index(before: self.rawLineBuffer.last!.endIndex))
            } else {
                self.rawLineBuffer.removeLast()
            }
        }
        self.recalculateLineBuffer()
    }
    
    func processSerialData(_ data: UInt8) {
        // Check for control characters
        switch data {
        case 0x8: // Backspace
            self.deleteCharacter()
            
        case 0xA: // Line feed
            self.appendNewLine()
            
        default:
            if let str = String(bytes: [data], encoding: String.Encoding.ascii) {
                self.appendText(str)
            }
        }
    }
    
}
