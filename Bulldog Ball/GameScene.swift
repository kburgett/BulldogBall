//
//  GameScene.swift
//  PaperToss

import SpriteKit
import GameplayKit

enum GameState {
    case playing, menu
    static var current = GameState.playing
}

struct PhysicsCategory {
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let lBasket: UInt32 = 0x1 << 2
    static let rBasket: UInt32 = 0x1 << 3
    static let base: UInt32 = 0x1 << 4
    static let startG: UInt32 = 0x1 << 5
    static let endG: UInt32 = 0x1 << 6
}

// Touch Start and End Points
struct Touch {
    static var start = CGPoint()
    static var end = CGPoint()
}

// Constants
struct Constants {
    static var gravity = CGFloat()          // Gravity
    static var yVelocity = CGFloat()        // Initial Y Velocity
    static var airTime = TimeInterval()     // Time in the air
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    // Variables
    var grids = true
    var background = SKSpriteNode(imageNamed: "Background")
    var basketFront = SKSpriteNode(imageNamed: "Net")
    var basketBack = SKSpriteNode(imageNamed: "Backboard")
    var basketball = SKSpriteNode(imageNamed: "Basketball")
    
    var ball = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var rim = SKShapeNode()
    var endGround = SKShapeNode()       // The ground the basket exists
    var startGround = SKShapeNode()     // Where the paper ball starts
    
    var windLabel = SKLabelNode()
    
    var pi = CGFloat(Double.pi)
    var wind = CGFloat()
    var touchingBall = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        if UIDevice.current.userInterfaceIdiom == .phone{
            Constants.gravity = -6
            Constants.yVelocity = self.frame.height / 4
            Constants.airTime = 1.5
        }else{
            //iPad
        }
        physicsWorld.gravity = CGVector(dx: 0, dy: Constants.gravity)
        setUpGame()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing{
                if ball.contains(location){
                    Touch.start = location
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing && !ball.contains(location){
                    Touch.end = location
                    touchingBall = false
                    fire()
            }
        }
    }
    func setUpGame() {
        GameState.current = .playing
        let backgroundScale = CGFloat(background.frame.width / background.frame.height) // eg 1.4 as scale
        background.size.height = self.frame.height
        background.size.width = background.size.height * backgroundScale
        background.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        background.zPosition = 0
        
        self.addChild(background)
        
        let basketScale = CGFloat(basketBack.frame.width / basketBack.frame.height)
        basketBack.size.height = self.frame.height / 9
        basketBack.size.width = basketBack.size.height * basketScale
        basketBack.position = CGPoint(x: self.frame.width / 2, y: 2 * self.frame.height / 3)
        basketBack.zPosition = background.zPosition + 1
        
        self.addChild(basketBack)
        
        basketFront.size = basketBack.size
        basketFront.position = basketBack.position
        basketFront.zPosition = basketBack.zPosition + 3
        
        self.addChild(basketFront)
        
        startGround = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startGround.fillColor = .red
        startGround.strokeColor = .clear
        startGround.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startGround.zPosition = 10
        startGround.alpha = grids ? 1 : 0
        startGround.physicsBody = SKPhysicsBody(rectangleOf: startGround.frame.size)
        startGround.physicsBody?.categoryBitMask = PhysicsCategory.startG
        startGround.physicsBody?.collisionBitMask = PhysicsCategory.ball
        startGround.physicsBody?.contactTestBitMask = PhysicsCategory.none
        startGround.physicsBody?.affectedByGravity = false
        startGround.physicsBody?.isDynamic = false
        
        self.addChild(startGround)
        
        endGround = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 5))
        endGround.fillColor = .red
        endGround.strokeColor = .clear
        endGround.position = CGPoint(x: self.frame.width / 2, y: 2 * self.frame.height / 3 - basketFront.frame.height / 2)
        endGround.zPosition = 10
        endGround.alpha = grids ? 1 : 0
        endGround.physicsBody = SKPhysicsBody(rectangleOf: endGround.frame.size)
        endGround.physicsBody?.categoryBitMask = PhysicsCategory.endG
        endGround.physicsBody?.collisionBitMask = PhysicsCategory.ball
        endGround.physicsBody?.contactTestBitMask = PhysicsCategory.none
        endGround.physicsBody?.affectedByGravity = false
        endGround.physicsBody?.isDynamic = false
        
        self.addChild(endGround)
        
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: basketFront.frame.height / 2))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: basketFront.position.x - basketFront.frame.width / 2.5,  y: basketFront.position.y)
        leftWall.zPosition = 10
        leftWall.alpha = grids ? 1 : 0
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.lBasket
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.none
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.zRotation =  pi / 25
        self.addChild(leftWall)
        
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: basketFront.frame.height / 2))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: basketFront.position.x + basketFront.frame.width / 2.5,  y: basketFront.position.y)
        rightWall.zPosition = 10
        rightWall.alpha = grids ? 1 : 0
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.rBasket
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.none
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation =  -pi / 25
        
        self.addChild(rightWall)
        
        rim = SKShapeNode(rectOf: CGSize(width: basketFront.frame.width / 2, height: 3))
        rim.fillColor = .red
        rim.strokeColor = .clear
        rim.position = CGPoint(x: basketFront.position.x,  y: basketFront.position.y - basketFront.frame.height / 4)
        rim.zPosition = 10
        rim.alpha = grids ? 1 : 0
        rim.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rim.physicsBody?.categoryBitMask = PhysicsCategory.base
        rim.physicsBody?.collisionBitMask = PhysicsCategory.ball
        rim.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        rim.physicsBody?.affectedByGravity = false
        rim.physicsBody?.isDynamic = false

        self.addChild(rim)
        
        windLabel.text = "Wind = 0"
        windLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 4 / 5)
        windLabel.fontSize = self.frame.width / 10
        windLabel.zPosition = background.zRotation + 1
        
        self.addChild(windLabel)
        
        setWind()
        setBall()
    }
    
    func setBall() {
        basketball.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        ball = SKShapeNode(circleOfRadius: basketFront.frame.width / 1.5)
        ball.fillColor = grids ?  .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2,  y: startGround.position.y + ball.frame.height)
        ball.zPosition = 10
        
        basketball.size = ball.frame.size
        ball.addChild(basketball)
        
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "Basketball"), size: basketball.size)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.startG
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.base
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        
        self.addChild(ball)
    }
    
    func setWind() {
        let multi = CGFloat(50)
        let rnd = CGFloat(arc4random_uniform(UInt32(10))) - 5
        windLabel.text = "Wind: \(rnd)"
        wind = rnd * multi
    }
    
    func fire() {
         
        let xChange = Touch.end.x - Touch.start.x
        
        let angle = (atan(xChange / (Touch.end.y - Touch.start.y)) * 180 / pi)
        let amendedX = (tan(angle * pi / 180) * Constants.yVelocity) * 0.5
        
        // Throw it
        let throwVec = CGVector(dx: amendedX, dy: Constants.yVelocity)
        ball.physicsBody?.applyImpulse(throwVec, at: Touch.start)
        
        // Shrink into distance
        ball.run(SKAction.scale(by: 0.3, duration: Constants.airTime))
        
        //change collison bitMask
        let wait = SKAction.wait(forDuration: Constants.airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = PhysicsCategory.startG | PhysicsCategory.endG | PhysicsCategory.base | PhysicsCategory.lBasket | PhysicsCategory.rBasket
            self.ball.zPosition = self.background.zPosition + 2
        })
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Add Wind
        let windWait = SKAction.wait(forDuration: Constants.airTime / 3)
        let push = SKAction.applyImpulse(CGVector(dx: wind, dy: 0), duration: 1)
        ball.run(SKAction.sequence([wait,push]))
        
        self.run(SKAction.sequence([wait,changeCollision]))
         
        // Wait and Reset
        let wait3 = SKAction.wait(forDuration: 3)
        let reset = SKAction.run({
            self.setWind()
            self.setBall()
        })
        self.run(SKAction.sequence([wait3,reset]))
    }
}
