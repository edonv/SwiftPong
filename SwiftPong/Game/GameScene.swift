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
    
    fileprivate var topWall: SKShapeNode?
    fileprivate var bottomWall: SKShapeNode?
    fileprivate var gameBoard: SKShapeNode?

    var score: (p1: Int, p2: Int) = (0, 0)
    
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
        
        // Update score
        if let leftScoreLabel = self.leftScoreLabel,
           let rightScoreLabel = self.rightScoreLabel {
            leftScoreLabel.text = "\(score.p1)"
            rightScoreLabel.text = "\(score.p2)"
        }
    }
    
    // MARK: Internals
    
    private func setUpScene() {
        // Set physics contact delegate
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
//        self.physicsWorld.gravity.dx = self.physicsWorld.gravity.dy
        
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
            
            let physicsBody = SKPhysicsBody(rectangleOf: leftPaddleSprite.size)
            physicsBody.affectedByGravity = false
            physicsBody.category = .paddle
            physicsBody.collisionCategories = [.ball, .enclosingWall]
            physicsBody.isDynamic = false
            leftPaddleSprite.physicsBody = physicsBody
        }
        // Create reference to rightPaddle
        self.rightPaddleSprite = self.childNode(withName: "//rightPaddle") as? SKSpriteNode
        if let rightPaddleSprite = self.rightPaddleSprite {
            rightPaddleSprite.color = .init(named: "Player 2") ?? rightPaddleSprite.color
            
            let physicsBody = SKPhysicsBody(rectangleOf: rightPaddleSprite.size)
            physicsBody.affectedByGravity = false
            physicsBody.category = .paddle
            physicsBody.collisionCategories = [.ball, .enclosingWall]
            physicsBody.isDynamic = false
            rightPaddleSprite.physicsBody = physicsBody
        }
        
        // Create reference to ball, set up physics
        self.ballSprite = self.childNode(withName: "//ball") as? SKSpriteNode
        if let ballSprite = self.ballSprite,
           let texture = ballSprite.texture {
            let physicsBody = SKPhysicsBody(circleOfRadius: ballSprite.size.width / 2) // (texture: texture, size: ballSprite.size)
            physicsBody.friction = 0
            physicsBody.linearDamping = 0
            physicsBody.restitution = 1
            physicsBody.category = .ball
            physicsBody.collisionCategories = [.enclosingWall, .paddle]
            physicsBody.contactTestCategories = [.gameBoard]
            ballSprite.physicsBody = physicsBody
            
            resetBallNode()
        }
        
        // Create top/bottom wall nodes
        let wallPath = CGMutablePath()
        wallPath.move(to: .init(x: self.frame.minX, y: 0))
        wallPath.addLine(to: .init(x: self.frame.maxX, y: 0))
        let wallNode = SKShapeNode(path: wallPath)
        wallNode.strokeColor = .clear
        
        let wallPhysics = SKPhysicsBody(edgeChainFrom: wallPath)
        wallPhysics.category = .enclosingWall
        wallNode.physicsBody = wallPhysics
        
        self.topWall = wallNode.copy() as! SKShapeNode?
        self.bottomWall = wallNode.copy() as! SKShapeNode?
        
        if let topWall = self.topWall,
           let bottomWall = self.bottomWall {
            topWall.position.y = self.frame.maxY
            bottomWall.position.y = self.frame.minY
            self.addChild(topWall)
            self.addChild(bottomWall)
        }
        
        // Create game board node
        let boardNode = SKShapeNode(rect: self.frame)
        boardNode.name = "gameBoard"
        boardNode.isHidden = true
        
        let boardPhysics = SKPhysicsBody(rectangleOf: self.frame.size)
        boardPhysics.category = .gameBoard
        boardPhysics.isDynamic = false
        boardPhysics.affectedByGravity = false
        boardNode.physicsBody = boardPhysics
        
        self.gameBoard = boardNode
        if let gameBoard = self.gameBoard {
            self.addChild(gameBoard)
        }
    }
    
    private func resetBallNode() {
        ballSprite?.position = .zero
        ballSprite?.physicsBody?.velocity = .zero
        
        #warning("TODO: randomize initial force direction")
        ballSprite?.run(.sequence([
            .wait(forDuration: 1, withRange: 3),
            .applyImpulse(.init(dx: 100, dy: 100), duration: 0.1)
        ]))
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
    
    override func keyDown(with event: NSEvent) {
//        print(event.keyCode)
        
//        let keyPressed = event.charactersIgnoringModifiers
//        // do stuff to figure out which key is pressed
//        let key = "s"
//        // do stuff to figure out which direction and player that maps to
//        let direction = "UP"
//        let player = 2
//        
//        self.leftPaddleSprite?.run(.repeatForever(.moveTo(y: 10, duration: 1)), withKey: "movePlayer1")
    }
}
#endif
