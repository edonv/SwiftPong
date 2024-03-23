//
//  GameScene.swift
//  GameTest Shared
//
//  Created by Edon Valdman on 3/22/24.
//

import SpriteKit

// MARK: Core Scene Logic

class GameScene: SKScene {
    
    fileprivate var titleLabel: SKLabelNode?
    fileprivate var leftScoreLabel: SKLabelNode?
    fileprivate var rightScoreLabel: SKLabelNode?
    
    fileprivate var leftPaddleSprite: SKSpriteNode?
    fileprivate var rightPaddleSprite: SKSpriteNode?
    fileprivate var ballSprite: SKSpriteNode?

    // MARK: Instantiation
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    // MARK: SKScene Overrides
    
    /// This is called when the scene is placed in a view.
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    /// This is called every frame.
    override func update(_ currentTime: TimeInterval) {
        InputManager.shared.update()
    }
    
    // MARK: Internals
    
    private func setUpScene() {
        // Create reference to titleLabel
        self.titleLabel = self.childNode(withName: "//titleLabel") as? SKLabelNode
        if let titleLabel = self.titleLabel {
            titleLabel.alpha = 0.0
            titleLabel.run(.fadeIn(withDuration: 2.0))
        }
        
        // Create reference to leftScoreLabel
        self.leftScoreLabel = self.childNode(withName: "//leftScoreLabel") as? SKLabelNode
        if let leftScoreLabel = self.leftScoreLabel {
            leftScoreLabel.fontColor = .init(named: "Player 1")
        }
        // Create reference to rightScoreLabel
        self.rightScoreLabel = self.childNode(withName: "//rightScoreLabel") as? SKLabelNode
        if let rightScoreLabel = self.rightScoreLabel {
            rightScoreLabel.fontColor = .init(named: "Player 2")
        }
        
        // Create reference to leftPaddle
        self.leftPaddleSprite = self.childNode(withName: "//leftPaddle") as? SKSpriteNode
        if let leftPaddleSprite = self.leftPaddleSprite {
            leftPaddleSprite.color = .init(named: "Player 1") ?? leftPaddleSprite.color
        }
        // Create reference to rightPaddle
        self.rightPaddleSprite = self.childNode(withName: "//rightPaddle") as? SKSpriteNode
        if let rightPaddleSprite = self.rightPaddleSprite {
            rightPaddleSprite.color = .init(named: "Player 2") ?? rightPaddleSprite.color
        }
        // Create reference to ball
        self.ballSprite = self.childNode(withName: "//ball") as? SKSpriteNode
    }
}

// MARK: Shared Interactive Logic

extension GameScene {
    private func startTouches(at locations: [CGPoint]) {
        
    }
    
    private func moveTouches(at locations: [CGPoint]) {
        
    }
    
    private func endTouches(at locations: [CGPoint]) {
        
    }
}

#if !os(macOS)
// MARK: Touch-based event handling

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startTouches(at: touches.map { $0.location(in: self) })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveTouches(at: touches.map { $0.location(in: self) })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(at: touches.map { $0.location(in: self) })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(at: touches.map { $0.location(in: self) })
    }
}
#endif

#if os(macOS)
// MARK: Mouse-based event handling

extension GameScene {
    override func mouseDown(with event: NSEvent) {
        startTouches(at: [event.location(in: self)])
    }
    
    override func mouseDragged(with event: NSEvent) {
        moveTouches(at: [event.location(in: self)])
    }
    
    override func mouseUp(with event: NSEvent) {
        endTouches(at: [event.location(in: self)])
    }
}
#endif
