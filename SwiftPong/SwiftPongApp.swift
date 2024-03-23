//
//  SwiftPongApp.swift
//  SwiftPong
//
//  Created by Edon Valdman on 3/23/24.
//

import SwiftUI

@main
struct SwiftPongApp: App {
    @NSApplicationDelegateAdaptor(SwiftPongAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
