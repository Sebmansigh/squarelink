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
    
    private static var textNode: SKLabelNode = SKLabelNode(text: "")
    
    static func postText(text: String)
    {
        textNode.text = text
    }
    
    var bgcells = Array< Array<BGCell?>? >(repeating: nil, count: 13)
    var pieces: Array<Piece>? = nil
    var obstacles: Array<SKSpriteNode?>? = nil
    var level: UInt64 = 0
    var maxLevel: UInt64 = 1
    var WinState = false
    
    var leftLevelArrow: SKShapeNode? = nil
    var rightLevelArrow: SKShapeNode? = nil
    var gridholder: SKSpriteNode? = nil
    var UINodes: Array<SKNode> = [textNode]
    var levelNode: SKLabelNode? = nil
    
    
    
    override func didMove(to view: SKView) {
        let bg = childNode(withName: "background") as! SKSpriteNode
        bg.position = CGPoint(x: 0,y: 0)
        bg.size = frame.size
        
        gridholder = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: 400, height: 400))
        UINodes.append(gridholder!)
        
        gridholder!.position = CGPoint(x:0, y: frame.height/5)
        addChild(gridholder!)
        
        UINodes.append(bg)
        let defsize = CGSize(width:20,height:20)
        for i in 0...12{
            bgcells[i] = Array<BGCell?>(repeating: nil, count: 13)
            for j in 0...12{
                let thiscell = SKSpriteNode(color: UIColor.darkGray, size: defsize)
                bgcells[i]![j] = BGCell(node: thiscell)
                UINodes.append(thiscell)
                thiscell.position = CGPoint(x: (i-6)*30, y: (j-6)*30 + Int(frame.height) / 5)
                addChild(thiscell)
            }
        }
        
        let tray = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width:frame.width, height: frame.height/2))
        UINodes.append(tray)
        
        tray.position = CGPoint(x:0, y: -frame.height/4)
        addChild(tray)
        
        bgcells[ 0]![ 0]!.Node.size = CGSize(width:35,height:35)
        bgcells[12]![12]!.Node.size = CGSize(width:35,height:35)
        
        levelNode = SKLabelNode(text: "Loading...")
        levelNode?.fontName = "Avenir-Heavy"
        levelNode!.fontColor = UIColor.black
        levelNode!.fontSize = 64
        levelNode!.position = CGPoint(x: 0, y: 240 + Int(frame.height) / 5)
        UINodes.append(levelNode!)
        
        
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x:0,y:80), CGPoint(x:40,y:0), CGPoint(x:-40,y:0), CGPoint(x:0,y:80)])
        leftLevelArrow = SKShapeNode(path: path)
        rightLevelArrow = SKShapeNode(path: path)
        
        
        addChild(leftLevelArrow!)
        leftLevelArrow!.position = CGPoint(x:levelNode!.position.x-180, y: levelNode!.position.y+20)
        leftLevelArrow!.zRotation = CGFloat.pi/2
        
        addChild(rightLevelArrow!)
        rightLevelArrow!.position = CGPoint(x:levelNode!.position.x+180, y: levelNode!.position.y+20)
        rightLevelArrow!.zRotation = -CGFloat.pi/2
        
        UINodes.append(leftLevelArrow!)
        UINodes.append(rightLevelArrow!)
        
        LoadLevel(maxLevel)
        RedrawLevelArrows()
        BeginLoadedLevel()
        
        addChild(levelNode!)
        
        GameScene.textNode.fontName = "Avenir-Heavy"
        GameScene.textNode.fontColor = UIColor.black
        GameScene.textNode.fontSize = 32
        GameScene.textNode.position = CGPoint(x: 0, y: 300 + Int(frame.height) / 5)
        addChild(GameScene.textNode)
    }
    
    func LoadNextLevel()
    {
        LoadLevel(level+1)
    }
    
    func LoadPrevLevel()
    {
        LoadLevel(level-1)
    }
    
    func LoadLevel(_ newLevel: UInt64)
    {
        GameScene.postText(text: "Loading...")
        clearLevel()
        level = newLevel
        pieces = GenerateLevel(level: level)
        BeginLoadedLevel()
        GameScene.postText(text: "")
    }
    
    func clearLevel()
    {
        WinState = false
        if(level == 0)
        {
            return
        }
        
        for piece in pieces!
        {
            piece.RemoveFromUI()
        }
        pieces = nil
        
        if(obstacles!.count > 0)
        {
            for i in 0...obstacles!.count-1
            {
                obstacles![i]!.removeFromParent()
            }
            obstacles = nil
        }
        
        for i in 0...bgcells.count-1
        {
            for j in 0...bgcells[i]!.count-1
            {
                bgcells[i]![j]!.Clear()
            }
        }
    }
    
    func GenerateLevel(level: UInt64) -> Array<Piece> {
        
        let RandomSource = GKMersenneTwisterRandomSource()
        RandomSource.seed = (1234567890123456789 - (level * level * level * level * 32 / (256+(level*level*level))))
        
        let Path = GeneratePath(rand: RandomSource, level: level)
        let Pieces = GeneratePieces(rand: RandomSource, level: level, path: Path)
        obstacles = GenerateObstacles(rand: RandomSource, level: level)
        
        levelNode!.text = "Level " + String(level)
        
        return Pieces
    }
    
    func GeneratePath(rand: GKRandomSource, level: UInt64) -> Stack<SKSpriteNode>
    {
        
        let thiscell = SKSpriteNode(color: UIColor.black, size: CGSize(width:30,height:30))
        thiscell.position = bgcells[0]![0]!.Node.position
        addChild(thiscell)
        bgcells[0]![0]!.Accept(node: thiscell)
        
        let Path = Stack<SKSpriteNode>()
        Path.Push(data: thiscell)
        
        assert(GeneratePathPartial(rand: rand, path: Path, a: 0, b: 0, MaxPath: Int(23+level*2)))
        
        
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
        
        // Shuffle an array of direction vectors ( 2 swaps only, to prioritize the up & right directions! )
        var Dirs = [[0,1],[1,0],[0,-1],[-1,0]]
        let Dist = GKRandomDistribution(randomSource: rand, lowestValue: 0, highestValue: 3)
        for _ in 0...1
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
            
            //if you try to move into a cell that's off the grid, fail.
            if(aSel < 0 || aSel >= 13 || bSel < 0 || bSel >= 13)
            {
                continue;
            }
            
            //OPTIMIZATION CUT
            //  if you try to move at or near a wall, and you're moving away from the goal, fail because
            //you've cut off the goal and will fail anyway, eating up a lot of time in the process!
            if((a < 2 || a >= 11) && Dirs[i][1] == -1)
            {
                continue
            }
            if((b < 2 || b >= 11) && Dirs[i][0] == -1)
            {
                continue
            }
            
            let testcell = bgcells[aSel]![bSel]!
            
            //if the cell is occupied, fail
            if(testcell.Occupied())
            {
                continue
            }
            
            
            //if the cell is adjacent to another cell, fail.
            var test = true
            for j in 0...3
            {
                let aTest = aSel+Dirs[j][0]
                let bTest = bSel+Dirs[j][1]
                if(aTest < 0 || aTest >= 13 || bTest < 0 || bTest >= 13)
                {
                    continue
                }
                //don't count the previous cell in the path.
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
    
    
    func GeneratePieces(rand: GKRandomSource, level: UInt64, path: Stack<SKSpriteNode>) -> Array<Piece>
    {
        var AvgPieceSize = 9
        if(level > 15)
        {
            AvgPieceSize = 7
        }
        if(level > 30)
        {
            AvgPieceSize = 6
        }
        if(level > 50)
        {
            AvgPieceSize = 5
        }
        
        let NumPieces = path.count / AvgPieceSize
        var Fudging = path.count % AvgPieceSize
        
        var Pieces: Array<Piece> = []
        
        var Colors: Array<UIColor> = [];
        for i in 0...NumPieces-1
        {
            if(i % 8 == 0)
            {
                Colors = GenerateColors(rand: rand)
            }
            var FudgingUse = 0
            if(Fudging > 0)
            {
                if(Fudging % (NumPieces-i) == 0)
                {
                    FudgingUse = Fudging/(NumPieces-i)
                    Fudging -= FudgingUse
                }
                else
                {
                    let RandSource = GKRandomDistribution(randomSource: rand, lowestValue: 0, highestValue: NumPieces-i)
                    FudgingUse = Fudging/(NumPieces-i)
                    if(RandSource.nextInt() == 0)
                    {
                        FudgingUse += 1
                    }
                    Fudging -= FudgingUse
                }
            }
            var prevcell = path.PopForce()
            let ThisPiece = Piece(baseNode: prevcell)
            for _ in 1...AvgPieceSize+FudgingUse-1
            {
                let thiscell = path.PopForce();
                ThisPiece.Append(next:thiscell, dirX: Int(thiscell.position.x-prevcell.position.x)/30, dirY: Int(thiscell.position.y-prevcell.position.y)/30)
                prevcell = thiscell
            }
            ThisPiece.Color(color: Colors[i % 8])
            Pieces.append(ThisPiece)
        }
        return Pieces
    }
    
    
    func GenerateColors(rand: GKRandomSource) -> Array<UIColor>
    {
        let IndexDist = GKRandomDistribution(randomSource: rand, lowestValue: 0, highestValue: 7)
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
    
    func GenerateObstacles(rand: GKRandomSource, level: UInt64) -> Array<SKSpriteNode?>
    {
        if(level < 10)
        {
            return []
        }
        else
        {
            var NumObstacles = 10
            if(level > 25)
            {
                NumObstacles = 15
            }
            if(level > 35)
            {
                NumObstacles = 20
            }
            let Dist = GKRandomDistribution(randomSource: rand, lowestValue:0, highestValue:12)
            var Ret = Array<SKSpriteNode?>(repeating: nil, count: NumObstacles)
            for i in 0...NumObstacles-1
            {
                let obstacle = SKSpriteNode(color: UIColor.black, size: CGSize(width:25,height:25))
                var testcell = bgcells[0]![0]!
                while testcell.Occupied()
                {
                    testcell = bgcells[Dist.nextInt()]![Dist.nextInt()]!
                }
                obstacle.position = testcell.Node.position
                addChild(obstacle)
                testcell.Accept(node: obstacle)
                Ret[i] = obstacle
            }
            return Ret
        }
    }
    
    func BeginLoadedLevel() {
        for i in 0...pieces!.count-1
        {
            let rot = 2*CGFloat.pi*CGFloat(i)/CGFloat(pieces!.count)
            let radius = frame.height/8
            let Piece = pieces![i]
            Piece.InitialPosition = CGPoint(x: sin(rot)*radius, y: cos(rot)*radius - frame.height/4 + 90)
            Piece.MoveToPoint(point: Piece.InitialPosition)
            for _cellarray in bgcells
            {
                for Cell in _cellarray!
                {
                    let Occ = Cell!.Occupant
                    if(Occ != nil)
                    {
                        var ob = false
                        for o in obstacles!
                        {
                            if(o! == Occ!)
                            {
                                ob = true
                                break
                            }
                        }
                        if(!ob)
                        {
                            Cell!.Clear()
                        }
                    }
                }
            }
        }
    }
    
    func getSelectedPieceFromNodes(nodes: [SKNode]) -> Piece?
    {
        if(WinState)
        {
            return nil //Don't let the player move pieces from a winning board
        }
        if(pieces == nil)
        {
            return nil
        }
        for Node in nodes
        {
            var test = true
            for UINode in UINodes
            {
                if(Node == UINode)
                {
                    //Node is a UI node!
                    test = false
                    break
                }
            }
            if(test) //We've got a piece here, folks!
            {
                //find the piece the node belongs to
                for Piece in pieces!
                {
                    if(Piece.Contains(Node))
                    {
                        return Piece
                    }
                }
            }
        }
        return nil
    }
    
    func RedrawLevelArrows()
    {
        if(level == 1)
        {
            leftLevelArrow!.strokeColor = UIColor.black
            leftLevelArrow!.fillColor = UIColor.clear
            leftLevelArrow!.lineWidth = 3
        }
        else
        {
            leftLevelArrow!.fillColor = UIColor.black
        }
        if(level == maxLevel)
        {
            rightLevelArrow!.strokeColor = UIColor.black
            rightLevelArrow!.fillColor = UIColor.clear
            rightLevelArrow!.lineWidth = 3
        }
        else
        {
            rightLevelArrow!.fillColor = UIColor.black
        }
    }
    
    func CheckForVictory()
    {
        for Piece in pieces!
        {
            if(!Piece.Locked())
            {
                return
            }
        }
        //  Try to form a path of length equal to the sum of the size of all pieces,
        //returning if you fail.
        
        
        //You've satisfied the conditions and can move on to the next level
        
        GameScene.postText(text: "Level Complete!")
        if(level == maxLevel)
        {
            maxLevel += 1
            RedrawLevelArrows()
        }
        WinState = true
    }
    
    
    
    var touchStarted: CGPoint? = nil
    var pieceSelected: Piece? = nil
    //var pieceClone: Piece? = nil
    func touchDown(touch: UITouch, atPoint pos : CGPoint) {
        let nodesUnderTouch = nodes(at: pos)
        // check for piece selected
        let P = getSelectedPieceFromNodes(nodes: nodesUnderTouch)
        
        if(P != nil)
        {
            touchStarted = CGPoint(x: pos.x-P!.GetUIPosition().x, y: pos.y-P!.GetUIPosition().y)
            pieceSelected = P
            pieceSelected!.SetZPosition(zpos: 1.0)
            pieceSelected!.Unlock(grid: bgcells)
            //Don't interact with UI if a piece has been selected
            return
        }
        
        if(nodesUnderTouch.contains(leftLevelArrow!) && level > 1)
        {
            LoadPrevLevel()
            RedrawLevelArrows()
        }
        else if(nodesUnderTouch.contains(rightLevelArrow!) && level < maxLevel)
        {
            LoadNextLevel()
            RedrawLevelArrows()
        }
    }
    
    func touchMoved(touch: UITouch, toPoint pos : CGPoint) {
        if(pieceSelected != nil)
        {
            pieceSelected!.MoveToPoint(x: pos.x-touchStarted!.x, y: pos.y-touchStarted!.y)
            
            let OG = pieceSelected!.OverGrid(gridholder: gridholder!)
            
            if(OG != nil)
            {
                let baseSquare : BGCell = bgcells[OG!.0]![OG!.1]!
                pieceSelected!.MoveToPoint(point: baseSquare.Node.position)
            }
        }
    }
    
    func touchUp(touch: UITouch, atPoint pos : CGPoint) {
        pieceSelected?.SetZPosition(zpos:0.0)
        
        let OG = pieceSelected?.OverGrid(gridholder: gridholder!)
        
        if(OG != nil)
        {
            if(pieceSelected!.TryLock(gridholder: gridholder!, grid: bgcells))
            {
                CheckForVictory()
            }
            else
            {
                pieceSelected!.MoveToPoint(point: pieceSelected!.InitialPosition)
            }
        }
        
        pieceSelected = nil
        touchStarted = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches { self.touchDown(touch: t, atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(touch: t, toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches
        {
            self.touchMoved(touch: t, toPoint: t.location(in: self))
            self.touchUp(touch: t, atPoint: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(touch: t, atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
