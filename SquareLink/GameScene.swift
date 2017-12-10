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
    var bgcells = Array< Array<BGCell?>? >(repeating: nil, count: 13)
    var pieces: Array<Array<SKSpriteNode?>?>? = nil
    var level: UInt64 = 1
    override func didMove(to view: SKView) {
        let bg = childNode(withName: "background") as! SKSpriteNode
        
        bg.position = CGPoint(x: 0,y: 0)
        bg.size = frame.size
        
        for i in 0...12{
            bgcells[i] = Array<BGCell?>(repeating: nil, count: 13)
            for j in 0...12{
                let thiscell = SKSpriteNode(color: UIColor.darkGray, size: CGSize(width:20,height:20))
                bgcells[i]![j] = BGCell(node: thiscell)
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
    
    func GeneratePath(rand: GKRandomSource, level: UInt64) -> Stack<SKSpriteNode>
    {
        
        let thiscell = SKSpriteNode(color: UIColor.black, size: CGSize(width:30,height:30))
        thiscell.position = bgcells[0]![0]!.Node.position
        addChild(thiscell)
        bgcells[0]![0]!.Accept(node: thiscell)
        
        let Path = Stack<SKSpriteNode>()
        Path.Push(data: thiscell)
        
        assert(GeneratePathPartial(rand: rand, path: Path, a: 0, b: 0, MaxPath: Int(27+level*2)))
        /*
            while(true)
            {
                let thiscell = SKSpriteNode(color: UIColor.black, size: CGSize(width:30,height:30))
                Path.Push(data: thiscell)
                thiscell.position = bgcells[a]![b]!.Node.position
                addChild(thiscell)
         
                if((dist.nextInt() == 1 && a < 12) || b == 12)
                {
                    a+=1
                }
                else
                {
                    b+=1
                }
         
                if(a == 12 && b == 12)
                {
                    break;
                }
            }
        */
        return Path
    }
    
    func GeneratePathPartial(rand: GKRandomSource, path: Stack<SKSpriteNode>, a: Int, b:Int, MaxPath: Int) -> Bool
    {
        if( a == 12 && b == 12)
        {
            return true;
        }
        else if(MaxPath == 0)
        {
            return false;
        }
        
        // Shuffle an array of direction vectors ( 2 swaps only, to prioritize up-left! )
        var Dirs = [[0,1],[1,0],[0,-1],[-1,0]]
        let Dist = GKRandomDistribution(randomSource: rand, lowestValue: 0, highestValue: 3)
        for _ in 0...2
        {
            let fromPos = Dist.nextInt()
            let toPos = Dist.nextInt()
            let Hold = Dirs[toPos]
            Dirs[toPos] = Dirs[fromPos]
            Dirs[fromPos] = Hold
        }
        
        for i in 0...3
        {
            let aSel = a+Dirs[i][0]
            let bSel = b+Dirs[i][1]
            
            if(aSel < 0 || aSel >= 13 || bSel < 0 || bSel >= 13)
            {
                continue;
            }
            
            let testcell = bgcells[aSel]![bSel]!
            
            if(testcell.Occupied())
            {
                continue
            }
            
            
            
            var test = true
            for j in 0...3
            {
                let aTest = aSel+Dirs[j][0]
                let bTest = bSel+Dirs[j][1]
                if(aTest < 0 || aTest >= 13 || bTest < 0 || bTest >= 13)
                {
                    continue
                }
                if(a == aTest && b == bTest)
                {
                    continue
                }
                
                if(bgcells[aTest]![bTest]!.Occupied())
                {
                    test = false
                    break
                }
            }
            if(!test)
            {
                continue
            }
            
            //We know that the new position's good, so add the cell to the new position to the path!
            
            
            let thiscell = SKSpriteNode(color: UIColor.black, size: CGSize(width:30,height:30))
            thiscell.position = bgcells[aSel]![bSel]!.Node.position
            addChild(thiscell)
            testcell.Accept(node: thiscell)
            path.Push(data: thiscell)
            
            if(GeneratePathPartial(rand: rand, path: path, a: aSel, b: bSel, MaxPath: MaxPath-1))
            {
                return true
            }
            else
            {
                //That didn't work, remove the cell at this position...
                let thiscell = path.PopForce()
                thiscell.removeFromParent()
                testcell.Clear()
            }
        }
        return false
    }
    
    
    func GeneratePieces(rand: GKRandomSource, level: UInt64, path: Stack<SKSpriteNode>) -> Array<Array<SKSpriteNode?>?>?
    {
        return nil
    }
    
    func generateLevel(level: UInt64) -> Array<Array<SKSpriteNode?>?>? {
        
        let RandomSource = GKMersenneTwisterRandomSource()
        RandomSource.seed = (1234567890123456789 - (level * level * level * level * 32 / (256+(level*level*level))))
        
        let Path = GeneratePath(rand: RandomSource, level: level)
        return GeneratePieces(rand: RandomSource, level: level, path: Path)
        /*
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
        */
    }
    
    func generateColors(source: GKRandomSource) -> Array<UIColor>
    {
        let IndexDist = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: 7)
        var ColArr = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple, UIColor.cyan, UIColor.orange, UIColor.magenta]
        for _ in 0...255
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
