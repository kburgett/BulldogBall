//
//  GameScene.swift
//  Bulldog Ball
//
//  Created by Kristen and Claire on 11/25/18.
//  Copyright © 2018 Kristen Burgett. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case playing
    case menu
    static var current = GameState.playing
}

struct PhysicsCategory {
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let lBasket: UInt32 = 0x1 << 2
    static let rBasket: UInt32 = 0x1 << 3
    static let base: UInt32 = 0x1 << 4
    static let startGround: UInt32 = 0x1 << 5
    static let endGround: UInt32 = 0x1 << 6
}

struct TouchPoints {
    static var start = CGPoint()
    static var end = CGPoint()
}

struct Constants {
    static var gravity = CGFloat()
    static var yVal = CGFloat()
    static var airTime = TimeInterval()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Variables
    var grids = true
    
    var background = SKSpriteNode(imageNamed: "")
    var basketFront = SKSpriteNode(imageNamed: "FrontBasket")
    var basketBack = SKSpriteNode(imageNamed: "Backboard")
    var basketball = SKSpriteNode(imageNamed: "Basketball")
    
    var ball = SKShapeNode()
    var leftNet = SKShapeNode()
    var rightNet = SKShapeNode()
    var base = SKShapeNode()
    var startG = SKShapeNode()      // Ground that basket exists on
    var endG = SKShapeNode()        // Ground where the basketball sits on
    
    var pi = CGFloat(M_PI)
    var touchingBall = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            Constants.gravity = -6
            Constants.yVal = self.frame.height / 4
            Constants.airTime = 2
        } else {
            // iPad graphics
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: Constants.gravity)
        
        setUpGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing {
                if ball.contains(location) {
                    TouchPoints.start = location
                    touchingBall = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing  && !ball.contains(location) && touchingBall {
                TouchPoints.end = location
                touchingBall = false
                fire()
            }
        }
    }
    
    func setUpGame() {
        GameState.current = .playing
    }
    
    func fire() {
        
    }
}







//
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//
//    override func didMove(to view: SKView) {
//
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
