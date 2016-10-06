//
//  GrifDocument.swift
//  Grif65
//
//  Created by Andy Best on 06/10/2016.
//  Copyright © 2016 andybest. All rights reserved.
//

import Foundation
import AppKit

class GrifDocument: NSDocument {
    
    var serialWindowController: SerialEmulatorWindowController?
    var emulatorController: GrifEmulatorController?
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    override func makeWindowControllers() {
        self.serialWindowController = SerialEmulatorWindowController(windowNibName: "SerialEmulatorWindow")
        addWindowController(self.serialWindowController!)
        
        self.emulatorController = GrifEmulatorController()
        self.emulatorController!.serialWindowController = self.serialWindowController!
        self.serialWindowController!.delegate = self.emulatorController!
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
}
