//
//  Scene.swift
//  WristGolf Watch App
//
//  Created by Giuseppe Francione on 18/06/24.
//

import Foundation
import SpriteKit
import CoreMotion
import SwiftUI

struct CollisionCategories {
    static let none: UInt32 = 0
    static let ball: UInt32 = 0x1 << 0
    static let hole: UInt32 = 0x1 << 1
    static let edge: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let queue = OperationQueue()
    let motionManager = CMMotionManager()
    var ball = SKShapeNode()
    var hole = SKShapeNode()
    func startGyroscope() {
        print("Provo a prendere gyro data")
#if !os(watchOS)
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0 / 10.0
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] (gyroData, error) in
                guard let self = self, let gyroData = gyroData else { return }
                let rotationRate = gyroData.rotationRate
                self.physicsWorld.gravity = CGVector(dx: rotationRate.y * 5, dy: -rotationRate.x * 5)
            }
        }
#else
        motionManager.gyroUpdateInterval = 1.0 / 10.0
        self.motionManager.startDeviceMotionUpdates(to: queue) { motion, error in
            print("arrivano!")
            
            if motion != nil {
                print("Motion: \(motion?.rotationRate)")
                let rotationRate = motion!.rotationRate
                if absValue(rotationRate) > 0.3 {
                    self.physicsWorld.gravity = CGVector(dx: rotationRate.y * 5, dy: -rotationRate.x * 5)
                }
            }
            
            if error != nil {
                print("ERROR: \(error!.localizedDescription)")
            }
        }
#endif
        
    }
    override init() {
#if !os(watchOS)
        super.init(size: UIScreen.main.bounds.size)
#else
        super.init(size: WKInterfaceDevice.current().screenBounds.size)
#endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        print("Scene loaded")
        self.backgroundColor = UIColor(Color(hex: "8EF283"))
        physicsWorld.contactDelegate = self
        physicsBody?.node?.name = "physicsNode"
        setupGame()
        spawnBall()
        spawnHole()
    }
    
    func setupGame() {
        self.scene?.scaleMode = .aspectFill
        startGyroscope()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    func spawnBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.name = "ball"
        ball.fillColor = .white
        ball.strokeColor = .white
        ball.position = CGPoint(x: 100, y: 100)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = CollisionCategories.ball
        ball.physicsBody?.collisionBitMask = CollisionCategories.edge
        ball.physicsBody?.contactTestBitMask = CollisionCategories.hole
        ball.zPosition = 3
        addChild(ball)
    }
    
    func spawnHole() {
        hole = SKShapeNode(circleOfRadius: 15)
        hole.name = "hole"
        hole.fillColor = .black
        hole.strokeColor = .black
        hole.position = CGPoint(x: CGFloat.random(in: 0...frame.width/2), y: CGFloat.random(in: 0...frame.height/2))
        hole.zPosition = 2
        hole.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        hole.physicsBody?.isDynamic = false
        hole.physicsBody?.categoryBitMask = CollisionCategories.hole
        hole.physicsBody?.collisionBitMask = CollisionCategories.none
        hole.physicsBody?.contactTestBitMask = CollisionCategories.ball
        addChild(hole)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if (firstBody.categoryBitMask == CollisionCategories.ball && secondBody.categoryBitMask == CollisionCategories.hole) ||
            (firstBody.categoryBitMask == CollisionCategories.hole && secondBody.categoryBitMask == CollisionCategories.ball) {
            print("Ball entered the hole!")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func gameOver() {
        motionManager.stopGyroUpdates()
    }
}

import SwiftUI

#Preview {
    SceneView()
}
