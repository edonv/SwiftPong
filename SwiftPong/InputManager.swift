//
//  InputManager.swift
//  SwiftPong
//
//  Created by Michael Martz on 3/23/24.
//

import Foundation
import GameController

class InputManager {
    static let shared = InputManager()
    
    private var movementByPlayer: [Float] = [0.0, 0.0]
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidConnect), name: NSNotification.Name.GCKeyboardDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisconnect), name: NSNotification.Name.GCKeyboardDidDisconnect, object: nil)
        
        if GCKeyboard.coalesced != nil {
            keyboardDidConnect()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getMovement(forPlayer playerIndex: Int) -> Float {
        guard playerIndex < movementByPlayer.count else {
            print("There aren't that many players!")
            abort()
        }
        
        return movementByPlayer[playerIndex]
    }
    

    @objc func keyboardDidConnect() {
        print("Keyboard connected!")
    }

    @objc func keyboardDidDisconnect() {
        print("Keyboard disconnected!")
    }
    
    func update() {
        guard let keyboard = GCKeyboard.coalesced?.keyboardInput else {
            return
        }
        
        movementByPlayer[0] = 0.0
        movementByPlayer[1] = 0.0
        
        if (keyboard.button(forKeyCode: .keyD)?.isPressed != nil) { movementByPlayer[0] += 1.0 }
        if (keyboard.button(forKeyCode: .keyW)?.isPressed != nil) { movementByPlayer[0] -= 1.0 }
    }
}
