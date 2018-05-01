//
//  WindowController.swift
//  Project04
//
//  Created by Tyler Arnold on 5/1/18.
//  Copyright © 2018 Tyler Arnold. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    @IBOutlet var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titleVisibility = .hidden
    }

}
