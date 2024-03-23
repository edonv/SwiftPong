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
    private var movementByPlayer: [Float] = []
    
    func GetMovement(forPlayer playerIndex: Int) -> Float {
        guard playerIndex < movementByPlayer.count else {
            print("There aren't that many players!")
            abort()
        }
        
        return movementByPlayer[playerIndex]
    }
    
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
        
        keyboard.button(forKeyCode: .keyA)
    }
}
