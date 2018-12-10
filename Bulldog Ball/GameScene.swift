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
    static let sG: UInt32 = 0x1 << 5
    static let eG: UInt32 = 0x1 << 6
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
    var bFront = SKSpriteNode(imageNamed: "binFront")
    var bBack = SKSpriteNode(imageNamed: "binBack")
    var bBall = SKSpriteNode(imageNamed: "paperBallImage")
    
    var ball = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var base = SKShapeNode()
    var endG = SKShapeNode()    //The ground the bin sits on
    var startG = SKShapeNode()  //Where the paper ball starts
    
    var windLbl = SKLabelNode()
    
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
        let bgScale = CGFloat(background.frame.width / background.frame.height) // eg 1.4 as scale
        background.size.height = self.frame.height
        background.size.width = background.size.height * bgScale
        background.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        background.zPosition = 0
        
        self.addChild(background)
        
        let binScale = CGFloat(bBack.frame.width / bBack.frame.height)
        bBack.size.height = self.frame.height / 9
        bBack.size.width = bBack.size.height * binScale
        bBack.position = CGPoint(x: self.frame.width/2, y: self.frame.height/3)
        bBack.zPosition = background.zPosition + 1
        
        self.addChild(bBack)
        
        bFront.size = bBack.size
        bFront.position = bBack.position
        bFront.zPosition = bBack.zPosition + 3
        
        self.addChild(bFront)
        
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startG.zPosition = 10
        startG.alpha = grids ? 1 : 0
        startG.physicsBody = SKPhysicsBody(rectangleOf: startG.frame.size)
        startG.physicsBody?.categoryBitMask = PhysicsCategory.sG
        startG.physicsBody?.collisionBitMask = PhysicsCategory.ball
        startG.physicsBody?.contactTestBitMask = PhysicsCategory.none
        startG.physicsBody?.affectedByGravity = false
        startG.physicsBody?.isDynamic = false
        
        self.addChild(startG)
        
        endG = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 5))
        endG.fillColor = .red
        endG.strokeColor = .clear
        endG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3 - bFront.frame.height / 2)
        endG.zPosition = 10
        endG.alpha = grids ? 1 : 0
        endG.physicsBody = SKPhysicsBody(rectangleOf: endG.frame.size)
        endG.physicsBody?.categoryBitMask = PhysicsCategory.eG
        endG.physicsBody?.collisionBitMask = PhysicsCategory.ball
        endG.physicsBody?.contactTestBitMask = PhysicsCategory.none
        endG.physicsBody?.affectedByGravity = false
        endG.physicsBody?.isDynamic = false
        
        self.addChild(endG)
        
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 1.6))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: bFront.position.x - bFront.frame.width / 2.5,  y: bFront.position.y)
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
        
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 1.6))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: bFront.position.x + bFront.frame.width / 2.5,  y: bFront.position.y)
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
        
        base = SKShapeNode(rectOf: CGSize(width: bFront.frame.width / 2, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.position = CGPoint(x: bFront.position.x,  y: bFront.position.y - bFront.frame.height / 4)
        base.zPosition = 10
        base.alpha = grids ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        base.physicsBody?.categoryBitMask = PhysicsCategory.base
        base.physicsBody?.collisionBitMask = PhysicsCategory.ball
        base.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false

        self.addChild(base)
        
        windLbl.text = "Wind = 0"
        windLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 4 / 5)
        windLbl.fontSize = self.frame.width / 10
        windLbl.zPosition = background.zRotation + 1
        
        self.addChild(windLbl)
        
        setWind()
        setBall()
    }
    
    func setBall(){
        bBall.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        ball = SKShapeNode(circleOfRadius: bFront.frame.width / 1.5)
        ball.fillColor = grids ?  .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2,  y: startG.position.y + ball.frame.height)
        ball.zPosition = 10
        
        bBall.size = ball.frame.size
        ball.addChild(bBall)
        
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "paperBallImage"), size: bBall.size)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.sG
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.base
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        
        self.addChild(ball)
    }
    
    func setWind() {
        
        let multi = CGFloat(50)
        let rnd = CGFloat(arc4random_uniform(UInt32(10))) - 5
        
        windLbl.text = "Wind: \(rnd)"
        
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
            self.ball.physicsBody?.collisionBitMask = PhysicsCategory.sG | PhysicsCategory.eG | PhysicsCategory.base | PhysicsCategory.lBasket | PhysicsCategory.rBasket
            self.ball.zPosition = self.background.zPosition + 2
        })
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Add Wind
        let windWait = SKAction.wait(forDuration: Constants.airTime / 4)
        let push = SKAction.applyImpulse(CGVector(dx: wind, dy: 0), duration: 1)
        ball.run(SKAction.sequence([wait,push]))
        
        self.run(SKAction.sequence([wait,changeCollision]))
         
        // Wait and Reset
        let wait4 = SKAction.wait(forDuration: 4)
        let reset = SKAction.run({
            self.setWind()
            self.setBall()
        })
        self.run(SKAction.sequence([wait4,reset]))
    }
}
