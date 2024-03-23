//
//  GameView.swift
//  SwiftUIGameTest
//
//  Created by Edon Valdman on 3/22/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject
    private var appDelegate: AppDelegate
    
    var body: some View {
        SpriteView(
            scene: appDelegate.gameScene,
            transition: .crossFade(withDuration: 2),
            isPaused: false,
            preferredFramesPerSecond: 60,
            options: .ignoresSiblingOrder,
            debugOptions: [.showsFPS, .showsNodeCount]
        )
        .ignoresSafeArea()
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

