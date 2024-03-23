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
        setUpObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidConnect), name: .GCKeyboardDidConnect, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidDisconnect),
            name: .GCKeyboardDidDisconnect,
            object: nil
        )
        
        if GCKeyboard.coalesced != nil {
            keyboardDidConnect()
        }
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
        guard let keyboard = GCKeyboard.coalesced?.keyboardInput else { return }
        
        movementByPlayer[0] = 0.0
        movementByPlayer[1] = 0.0
        
        movementByPlayer[0] += keyboard.button(forKeyCode: .keyS)?.isPressed == true ? 1.0 : 0.0
        movementByPlayer[0] -= keyboard.button(forKeyCode: .keyW)?.isPressed == true ? 1.0 : 0.0
    }
}

// MARK: Unused Combine code

//import Combine

//enum ControllerMode {
//    case keyboard(GCKeyboard)
//    case keyboardGamepad(player1: GCKeyboard, player2: GCExtendedGamepad)
//    case gamepadKeyboard(player1: GCExtendedGamepad, player2: GCKeyboard)
//    case dualGamepad(player1: GCExtendedGamepad, player2: GCExtendedGamepad)
//}

//func combineTemp() {
//    let keyboardConnect = NotificationCenter.default.publisher(for: .GCKeyboardDidConnect)
//        .compactMap { notif in
//            notif.object as? GCKeyboard
//        }
//        // Create 1-time publisher to check if there is already a keyboard connected
//        .merge(with: Just(GCKeyboard.coalesced).compactMap { $0 })
//        .map { $0 as GCKeyboard? }
//
//    let keyboardConnection = NotificationCenter.default.publisher(for: .GCKeyboardDidDisconnect)
//        .map { _ in nil as GCKeyboard? }
//        .merge(with: keyboardConnect)
//        .eraseToAnyPublisher()
//
//    let controllerConnect = NotificationCenter.default.publisher(for: .GCControllerDidConnect)
//        .compactMap { notif in
//            notif.object as? GCController
//        }
//        // Create 1-time publisher to check if there is already a keyboard connected
//        .merge(with: Just(GCController.current).compactMap { $0 })
//        .map { $0 as GCController? }
//
//    let controllerConnection = NotificationCenter.default.publisher(for: .GCControllerDidDisconnect)
//        .map { _ in nil as GCController? }
//        .merge(with: controllerConnect)
//        .eraseToAnyPublisher()
//
//    Publishers.CombineLatest(
//        keyboardConnection,
//        controllerConnection
//    )
//    .map { (keyboard: GCKeyboard?, controller: GCController?) -> ControllerMode? in
//        if let keyboard = keyboard,
//           let controller = controller {
//            return
//        }
//    }
//}
