//
//  GameScene.swift
//  GameTest Shared
//
//  Created by Edon Valdman on 3/22/24.
//

import SpriteKit
import GameplayKit

// MARK: Core Scene Logic

class GameScene: SKScene {
    
    fileprivate var titleLabel: SKLabelNode?
    fileprivate var leftScoreLabel: SKLabelNode?
    fileprivate var rightScoreLabel: SKLabelNode?
    
    fileprivate var leftPaddle: SKSpriteNode?
    fileprivate var rightPaddle: SKSpriteNode?
    fileprivate var ball: SKSpriteNode?
    
    fileprivate var topWall: SKShapeNode?
    fileprivate var bottomWall: SKShapeNode?
    fileprivate var gameBoard: SKShapeNode?

    var score: (p1: Int, p2: Int) = (0, 0)
    var shouldResetBall = false
    
    let paddleSpeed: Float = 15
    let initialBallSpeed: Float = 141.4213562373
    let randomNumberGenerator = GKARC4RandomSource()
    let minimumBallVelocityThreshold: CGFloat = 1
    
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
        // Update controller input
        InputManager.shared.update()
        
        // Update paddle position
        leftPaddle?.position.y += CGFloat(InputManager.shared.getMovement(forPlayer: 0) * paddleSpeed)
        rightPaddle?.position.y += CGFloat(InputManager.shared.getMovement(forPlayer: 1) * paddleSpeed)
        let paddleYPosRange = (bottomWall?.position.y ?? 0.0)...(topWall?.position.y ?? 0.0)
        if let leftPaddle = self.leftPaddle {
            leftPaddle.position.y = leftPaddle.position.y
                .clamped(to: paddleYPosRange)
            
        }
        if let rightPaddle = self.rightPaddle {
            rightPaddle.position.y = rightPaddle.position.y
                .clamped(to: paddleYPosRange)
        }
        
        // Update score
        if let leftScoreLabel = self.leftScoreLabel,
           let rightScoreLabel = self.rightScoreLabel {
            leftScoreLabel.text = "\(score.p1)"
            rightScoreLabel.text = "\(score.p2)"
        }
        
        // When score changes, move ball back to center, delay, then start moving
        if shouldResetBall {
            resetBallNode()
            shouldResetBall = false
        }
        
        // Confirm ball is inside the game frame
        if let ballFrame = ball?.frame,
           let gameBoardFrame = gameBoard?.frame,
           !gameBoardFrame.contains(ballFrame),
           let ballPos = ball?.position {
            // Only add points if it's out of bounds on the X axis
            // Compare leading edges of ball and board, and trailing edges too
            if ballFrame.minX < gameBoardFrame.minX
                || ballFrame.maxX > gameBoardFrame.maxX {
                let p1Pt = ballPos.x.sign == .minus
                score.p1 += p1Pt ? 1 : 0
                score.p2 += !p1Pt ? 1 : 0
            }
            
            // Reset ball if it's out of the game frame
            shouldResetBall = true
        }
    }
    
    // MARK: Internals
    
    private func setUpScene() {
        // Set physics contact delegate
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
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
        self.leftPaddle = self.childNode(withName: "//leftPaddle") as? SKSpriteNode
        if let leftPaddle = self.leftPaddle {
            leftPaddle.color = .init(named: "Player 1") ?? leftPaddle.color
            
            let physicsBody = SKPhysicsBody(rectangleOf: leftPaddle.size)
            physicsBody.affectedByGravity = false
            physicsBody.category = .paddle
            physicsBody.collisionCategories = [.ball, .enclosingWall]
            physicsBody.isDynamic = false
            leftPaddle.physicsBody = physicsBody
        }
        // Create reference to rightPaddle
        self.rightPaddle = self.childNode(withName: "//rightPaddle") as? SKSpriteNode
        if let rightPaddle = self.rightPaddle {
            rightPaddle.color = .init(named: "Player 2") ?? rightPaddle.color
            
            let physicsBody = SKPhysicsBody(rectangleOf: rightPaddle.size)
            physicsBody.affectedByGravity = false
            physicsBody.category = .paddle
            physicsBody.collisionCategories = [.ball, .enclosingWall]
            physicsBody.isDynamic = false
            rightPaddle.physicsBody = physicsBody
        }
        
        // Create reference to ball, set up physics
        self.ball = self.childNode(withName: "//ball") as? SKSpriteNode
        if let ball = self.ball,
           let texture = ball.texture {
            let physicsBody = SKPhysicsBody(texture: texture, size: ball.size)
            physicsBody.friction = 0
            physicsBody.linearDamping = 0
            physicsBody.restitution = 1
            physicsBody.category = .ball
            physicsBody.collisionCategories = [.enclosingWall, .paddle]
            physicsBody.contactTestCategories = [.gameBoard]
            physicsBody.allowsRotation = false
            ball.physicsBody = physicsBody
            
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
        ball?.position = .zero
        ball?.physicsBody?.velocity = .zero
        ball?.physicsBody?.angularVelocity = .zero
        
        var randomAngle = randomNumberGenerator.nextUniform() * .pi * 0.8 + .pi * 0.1
        if randomNumberGenerator.nextInt(upperBound: 2) == 1 { randomAngle += .pi }
        
        let impulseX = sin(randomAngle) * initialBallSpeed
        let impulseY = cos(randomAngle) * initialBallSpeed
        let impulse = CGVector(dx: CGFloat(impulseX), dy: CGFloat(impulseY))
        
        ball?.run(.sequence([
            .wait(forDuration: 1, withRange: 3),
            .applyImpulse(impulse, duration: 0.1)
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
