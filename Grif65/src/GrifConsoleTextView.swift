//
//  GrifConsoleTextView.swift
//  Grif65
//
//  Created by Andy Best on 09/08/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Cocoa

class GrifConsoleTextView: NSView {
    
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
        rawLineBuffer.append("Hello, world!")
        rawLineBuffer.append("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a nisl felis. Donec nunc nisl, sodales at urna at, eleifend suscipit mauris. Pellentesque tincidunt faucibus magna, ut consequat lorem ultrices vel. Etiam ac mi ornare, congue enim at, scelerisque enim. Curabitur posuere odio neque, quis iaculis lorem lacinia quis. Nunc rhoncus mauris et felis auctor, et pulvinar urna commodo. Aliquam consectetur congue leo, nec gravida metus iaculis vel. Nullam hendrerit a enim et vehicula.")
        rawLineBuffer.append("")
        rawLineBuffer.append("Suspendisse potenti. Sed lobortis enim non tristique faucibus. Pellentesque finibus vel quam ac viverra. Cras id ultricies arcu. Donec a arcu turpis. Maecenas sit amet metus turpis. Ut tempor laoreet nibh, id faucibus tortor. Integer efficitur augue quis nunc interdum, quis venenatis tortor dictum. Quisque at maximus leo. Integer eros massa, consectetur in lobortis sodales, euismod et ligula. Donec tempus ut elit in dictum. Sed varius accumsan neque, ut semper lorem ornare quis. Nunc feugiat diam at mi maximus fermentum. Duis ligula odio, lacinia in aliquam a, gravida id metus. Fusce accumsan risus in magna facilisis, a cursus lectus dapibus. Nullam eu tortor eu magna scelerisque dapibus.")
        rawLineBuffer.append("")
        rawLineBuffer.append("Morbi purus nulla, faucibus vel placerat eu, elementum a nunc. Nam scelerisque erat odio, a molestie enim aliquam eu. Nunc sit amet consequat libero. Sed eu mollis velit. Suspendisse hendrerit, sapien id consequat aliquam, mi libero fermentum risus, a semper magna metus vel orci. Pellentesque in mi enim. Quisque eget risus at tellus ornare sagittis. Praesent lacinia viverra lorem, in sollicitudin enim elementum id. Morbi pretium suscipit ipsum vel posuere.")
        recalculateLineBuffer()
        
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
        if self.screenLineBuffer.last!.characters.count >= Int(self.terminalSize().width) {
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
    }
    
    override func insertText(_ insertString: AnyObject) {
        if self.rawLineBuffer.count > 0 {
            self.rawLineBuffer[self.rawLineBuffer.count - 1] += insertString as! String
        } else {
            self.rawLineBuffer.append(insertString as! String)
        }
        //self.string! += (insertString as! String)
        
        recalculateLineBuffer()
    }
    
    override func moveUp(_ sender: AnyObject?) {
        Swift.print("Up arrow.")
    }
    
    override func moveLeft(_ sender: AnyObject?) {
        Swift.print("Left arrow.")
    }
    
    override func deleteBackward(_ sender: AnyObject?) {
        if self.rawLineBuffer.count > 0 {
            if self.rawLineBuffer.last!.characters.count > 0 {
                self.rawLineBuffer[self.rawLineBuffer.count - 1].remove(at: self.rawLineBuffer.last!.index(before: self.rawLineBuffer.last!.endIndex))
            } else {
                self.rawLineBuffer.removeLast()
            }
        }
        self.recalculateLineBuffer()
    }
    
    override func insertNewline(_ sender: AnyObject?) {
        self.rawLineBuffer.append("")
        self.recalculateLineBuffer()
    }
    
}
