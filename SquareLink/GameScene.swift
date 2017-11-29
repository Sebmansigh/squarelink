//
//  GameScene.swift
//  SquareLink
//
//  Created by Sebastian Snyder on 11/29/17.
//  Copyright © 2017 Sebastian Snyder. All rights reserved.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene {
    var bgcells = Array< Array<SKSpriteNode?>? >(repeating: nil, count: 10)
    
    override func didMove(to view: SKView) {
        let bg = childNode(withName: "background") as! SKSpriteNode
        
        bg.position = CGPoint(x: 0,y: 0)
        bg.size = frame.size
        
        for i in 0...10{
            bgcells[i] = Array<SKSpriteNode?>(repeating: nil, count: 10)
            for j in 0...10{
                var thiscell = SKSpriteNode(color: UIColor.darkGray, size: CGSize(width:10,height:10))
                bgcells[i]![j] = thiscell
                thiscell.position = CGPoint(x: 10+i*10, y: 10+j*10)
                addChild(thiscell)
            }
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
