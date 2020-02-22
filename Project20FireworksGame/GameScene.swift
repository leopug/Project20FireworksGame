//
//  GameScene.swift
//  Project20FireworksGame
//
//  Created by Ana Caroline de Souza on 20/02/20.
//  Copyright © 2020 Ana e Leo Corp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  
      var gameTimer: Timer!
      var fireworks = [SKNode]()
      var gameScore : SKLabelNode!
      var gameMaxRounds = 3
      var gameRound = 0
    
      let leftEdge = -22
      let bottomEdge = -22
      let rightEdge = 1024 + 22

      var score = 0 {
          didSet {
            gameScore.text = "Score: \(score)"
          }
      }

      override func didMove(to view: SKView) {
            let background = SKSpriteNode(imageNamed: "background")
            background.position = CGPoint(x: 512, y: 384)
            background.blendMode = .replace
            background.zPosition = -1
            addChild(background)

            gameScore = SKLabelNode(fontNamed: "Chalkduster")
            gameScore.fontColor = UIColor.white
            gameScore.text = "Score: 0"
            gameScore.position = CGPoint(x: 8, y: 8)
            gameScore.horizontalAlignmentMode = .left
            gameScore.fontSize = 48
            addChild(gameScore)

          gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
      }

      func createFirework(xMovement: CGFloat, x: Int, y: Int) {
          let node = SKNode()
          node.position = CGPoint(x: x, y: y)

          let firework = SKSpriteNode(imageNamed: "rocket")
          firework.colorBlendFactor = 1
          firework.name = "firework"
          node.addChild(firework)

          switch Int.random(in: 0...2) {
          case 0:
              firework.color = .cyan

          case 1:
              firework.color = .green

          case 2:
              firework.color = .red

          default:
              break
          }

          let path = UIBezierPath()
          path.move(to: CGPoint(x: 0, y: 0))
          path.addLine(to: CGPoint(x: xMovement, y: 1000))

          let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
          node.run(move)

          let emitter = SKEmitterNode(fileNamed: "fuse")!
          emitter.position = CGPoint(x: 0, y: -22)
          node.addChild(emitter)

          fireworks.append(node)
          addChild(node)
      }

      @objc func launchFireworks() {
        
        if gameRound > gameMaxRounds {
            gameTimer.invalidate()
            return
        } else {
            gameRound+=1
        }
        
          let movementAmount: CGFloat = 1800

          switch Int.random(in: 0...3) {
          case 0:
              createFirework(xMovement: 0, x: 512, y: bottomEdge)
              createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
              createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
              createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
              createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

          case 1:
              createFirework(xMovement: 0, x: 512, y: bottomEdge)
              createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
              createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
              createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
              createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

          case 2:
              createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
              createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
              createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
              createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
              createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

          case 3:
              createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
              createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
              createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
              createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
              createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

          default:
              break
          }
      }

      func checkTouches(_ touches: Set<UITouch>) {
          guard let touch = touches.first else { return }

          let location = touch.location(in: self)
          let nodesAtPoint = nodes(at: location)

          for node in nodesAtPoint {
              if node is SKSpriteNode {
                  let sprite = node as! SKSpriteNode

                  if sprite.name == "firework" {
                      for parent in fireworks {
                          let firework = parent.children[0] as! SKSpriteNode

                          if firework.name == "selected" && firework.color != sprite.color {
                              firework.name = "firework"
                              firework.colorBlendFactor = 1
                          }
                      }

                      sprite.name = "selected"
                      sprite.colorBlendFactor = 0
                  }
              }
          }
      }

      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesBegan(touches, with: event)
          checkTouches(touches)
      }

      override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesMoved(touches, with: event)
          checkTouches(touches)
      }

      override func update(_ currentTime: TimeInterval) {
          for (index, firework) in fireworks.enumerated().reversed() {
              if firework.position.y > 900 {
                  fireworks.remove(at: index)
                  firework.removeFromParent()
              }
          }
      }

      func explode(firework: SKNode) {
          let emitter = SKEmitterNode(fileNamed: "explode")!
          emitter.position = firework.position
          addChild(emitter)

          firework.removeFromParent()
        
      }

      func explodeFireworks() {
          var numExploded = 0

          for (index, fireworkContainer) in fireworks.enumerated().reversed() {
              let firework = fireworkContainer.children[0] as! SKSpriteNode

              if firework.name == "selected" {
                  explode(firework: fireworkContainer)
                  fireworks.remove(at: index)
                  numExploded += 1
              }
          }

          switch numExploded {
          case 0:
              break
          case 1:
              score += 200
          case 2:
              score += 500
          case 3:
              score += 1500
          case 4:
              score += 2500
          default:
              score += 4000
          }
      }
    
}
