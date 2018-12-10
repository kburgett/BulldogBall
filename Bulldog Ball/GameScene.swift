//
//  GameScene.swift
//  PaperToss
//
//  Created by Michael Fischer on 11/26/18.
//  Copyright © 2018 Ellis Fischer. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case playing, menu
    static var current = GameState.playing
}

// Physics Category
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
    var grids = false
    var background = SKSpriteNode(imageNamed: "Background")
    var backboard = SKSpriteNode(imageNamed: "Backboard - No Net")
    var rimFront = SKSpriteNode(imageNamed: "RimFront")
    var rimBack = SKSpriteNode(imageNamed: "RimBack")
    var basketball = SKSpriteNode(imageNamed: "Basketball")
    
    var ball = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var base = SKShapeNode()
    var endGround = SKShapeNode()    // The ground the basket at the back of the court
    var startGround = SKShapeNode()  // Where the basketball starts
    
    var windLabel = SKLabelNode()
    
    var pi = CGFloat(Double.pi)
    var wind = CGFloat()
    var touchingBall = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        if UIDevice.current.userInterfaceIdiom == .phone{
            Constants.gravity = -6.5
            Constants.yVelocity = self.frame.height / 3
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
        let bgScale = CGFloat(background.frame.width / background.frame.height) // eg 1.4 as scale
        background.size.height = self.frame.height
        background.size.width = background.size.height * bgScale
        background.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        background.zPosition = 0
        
        self.addChild(background)
        
        let boardScale = CGFloat(backboard.frame.width / backboard.frame.height)
        backboard.size.height = self.frame.height / 4
        backboard.size.width = backboard.size.height * boardScale
        backboard.position = CGPoint(x: self.frame.width/2, y: 2*self.frame.height/3 + 1*self.backboard.size.height/4)
        backboard.zPosition = background.zPosition + 1
        
        self.addChild(backboard)
        
        let binScale = CGFloat(rimBack.frame.width / rimBack.frame.height)
        rimBack.size.height = self.frame.height / 9
        rimBack.size.width = rimBack.size.height * binScale
        rimBack.position = CGPoint(x: self.frame.width/2, y: 2*self.frame.height/3)
        rimBack.zPosition = background.zPosition + 2
        
        self.addChild(rimBack)
        
        rimFront.size = rimBack.size
        rimFront.position = rimBack.position
        rimFront.zPosition = rimBack.zPosition + 3
        
        self.addChild(rimFront)
        
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
        endGround.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3 - rimFront.frame.height / 2)
        endGround.zPosition = 10
        endGround.alpha = grids ? 1 : 0
        endGround.physicsBody = SKPhysicsBody(rectangleOf: endGround.frame.size)
        endGround.physicsBody?.categoryBitMask = PhysicsCategory.endG
        endGround.physicsBody?.collisionBitMask = PhysicsCategory.ball
        endGround.physicsBody?.contactTestBitMask = PhysicsCategory.none
        endGround.physicsBody?.affectedByGravity = false
        endGround.physicsBody?.isDynamic = false
        
        self.addChild(endGround)
        
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: rimFront.frame.height / 1.6))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: rimFront.position.x - rimFront.frame.width / 2.5,  y: rimFront.position.y)
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
        
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: rimFront.frame.height / 1.6))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: rimFront.position.x + rimFront.frame.width / 2.5,  y: rimFront.position.y)
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
        
        base = SKShapeNode(rectOf: CGSize(width: rimFront.frame.width / 2, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.position = CGPoint(x: rimFront.position.x,  y: rimFront.position.y)
        base.zPosition = 10
        base.alpha = grids ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        base.physicsBody?.categoryBitMask = PhysicsCategory.base
        base.physicsBody?.collisionBitMask = PhysicsCategory.ball
        base.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        
        self.addChild(base)
        
        windLabel.text = "Wind = 0"
        windLabel.position = CGPoint(x: self.frame.width / 2, y: 8 * self.frame.height / 9)
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
        
        ball = SKShapeNode(circleOfRadius: rimFront.frame.width / 1.5)
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
        
        // Throw It
        let throwVec = CGVector(dx: amendedX, dy: Constants.yVelocity)
        ball.physicsBody?.applyImpulse(throwVec, at: Touch.start)
        
        // Shrink
        ball.run(SKAction.scale(by: 0.6, duration: Constants.airTime))
        
        // Change Collison BitMask
        let wait = SKAction.wait(forDuration: Constants.airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = PhysicsCategory.startG | PhysicsCategory.endG | PhysicsCategory.base | PhysicsCategory.lBasket | PhysicsCategory.rBasket
            self.ball.zPosition = self.background.zPosition + 2
        })
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Add Wind
        let windWait = SKAction.wait(forDuration: Constants.airTime / 4)
        let push = SKAction.applyImpulse(CGVector(dx: wind, dy: 0), duration: 1)
        ball.run(SKAction.sequence([wait,push]))
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Wait and reset
        let wait3 = SKAction.wait(forDuration: 3)
        let reset = SKAction.run({
            self.setWind()
            self.setBall()
        })
        self.run(SKAction.sequence([wait3,reset]))
    }
}
