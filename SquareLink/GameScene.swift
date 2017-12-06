//
//  GameScene.swift
//  SquareLink
//
//  Created by Sebastian Snyder on 11/29/17.
//  Copyright © 2017 Sebastian Snyder. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene {
    var bgcells = Array< Array<SKSpriteNode?>? >(repeating: nil, count: 13)
    var pieces: Array<Array<SKSpriteNode?>?>? = nil
    var level: UInt64 = 1
    override func didMove(to view: SKView) {
        let bg = childNode(withName: "background") as! SKSpriteNode
        
        bg.position = CGPoint(x: 0,y: 0)
        bg.size = frame.size
        
        for i in 0...12{
            bgcells[i] = Array<SKSpriteNode?>(repeating: nil, count: 13)
            for j in 0...12{
                let thiscell = SKSpriteNode(color: UIColor.darkGray, size: CGSize(width:20,height:20))
                bgcells[i]![j] = thiscell
                thiscell.position = CGPoint(x: (i-6)*30, y: (j-6)*30 + Int(frame.height) / 5)
                addChild(thiscell)
            }
        }
        pieces = generateLevel(level: level)
    }
    
    func nextLevel()
    {
        clearLevel()
        level += 1
        pieces = generateLevel(level: level)
    }
    
    func clearLevel()
    {
        for i in 0...pieces!.count-1
        {
            for n in 0...pieces![i]!.count-1
            {
                pieces![i]![n]!.removeFromParent()
            }
        }
        pieces = nil
    }
    
    func generateLevel(level: UInt64) -> Array<Array<SKSpriteNode?>?> {
        
        let RandomSource = GKMersenneTwisterRandomSource()
        RandomSource.seed = (1234567890123456789 - (level * level * level * level * 32 / (256+(level*level*level))))
        let RandomDistribution = GKRandomDistribution(randomSource: RandomSource, lowestValue: 0, highestValue: 1)
        
        var Pieces = Array< Array<SKSpriteNode?>? >(repeating: nil, count: 5)
        
        var a = 0
        var b = 0
        
        var PieceColors = generateColors(source:RandomSource)
        
        for q in 0...4{
            var ThisPiece = Array<SKSpriteNode?>(repeating: nil, count: 5)
            for i in 0...4{
                let thiscell = SKSpriteNode(color: PieceColors[q], size: CGSize(width:30,height:30))
                ThisPiece[i] = thiscell
                thiscell.position = bgcells[a]![b]!.position
                addChild(thiscell)
                
                if((RandomDistribution.nextInt() == 1 && a < 12) || b == 12)
                {
                    a+=1
                }
                else
                {
                    b+=1
                }
            }
            Pieces[q] = ThisPiece
        }
        return Pieces
    }
    
    func generateColors(source: GKRandomSource) -> Array<UIColor>
    {
        let CheckDist = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: 255)
        let IndexDist = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: 7)
        var ColArr = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple, UIColor.cyan, UIColor.orange, UIColor.magenta]
        while(CheckDist.nextInt() != 255)
        {
            let fromPos = IndexDist.nextInt()
            let toPos = IndexDist.nextInt()
            let Hold = ColArr[toPos]
            ColArr[toPos] = ColArr[fromPos]
            ColArr[fromPos] = Hold
        }
        return ColArr
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        nextLevel()
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
