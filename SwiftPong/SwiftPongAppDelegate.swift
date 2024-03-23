//
//  SwiftPongAppDelegate.swift
//  SwiftPong
//
//  Created by Michael Martz on 3/23/24.
//

import Foundation
import AppKit

class SwiftPongAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
