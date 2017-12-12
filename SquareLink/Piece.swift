//
//  Piece.swift
//  SquareLink
//
//  Created by Sebastian Snyder on 12/9/17.
//  Copyright © 2017 Sebastian Snyder. All rights reserved.
//

import Foundation
import SpriteKit

class Piece
{
    var InitialPosition = CGPoint(x: 0,y: 0)
    
    private var Nodes: Array<SKSpriteNode>
    private var positions: Array<(Int,Int)>
    private var gamePosition: (Int,Int)?
    private var UIPosition: CGPoint
    private var vbounds: (Int,Int)
    private var hbounds: (Int,Int)
    
    init(baseNode: SKSpriteNode)
    {
        Nodes = [baseNode]
        positions = [(0,0)]
        gamePosition = nil
        UIPosition = CGPoint(x:0,y:0)
        vbounds = (0,0)
        hbounds = (0,0)
    }
    
    func GetPosition(index: Int) -> (Int,Int)
    {
        return (positions[index].0+gamePosition!.0, positions[index].1+gamePosition!.1)
    }
    
    func SetGamePosition(posX: Int, posY: Int)
    {
        return gamePosition = (posX,posY)
    }
    
    func ClearGamePosition()
    {
        gamePosition = nil
    }
    
    func Append(next:SKSpriteNode, dirX: Int, dirY: Int)
    {
        if(Count() == 0)
        {
            UIPosition = next.position
        }
        Nodes.append(next)
        let NextX = positions[positions.count-1].0+dirX
        let NextY = positions[positions.count-1].1+dirY
        if(NextX < hbounds.0)
        {
            hbounds.0 = NextX
        }
        else if(NextX > hbounds.1)
        {
            hbounds.1 = NextX
        }
        if(NextY < vbounds.0)
        {
            vbounds.0 = NextY
        }
        else if(NextY > vbounds.1)
        {
            vbounds.1 = NextY
        }
        positions.append((NextX,NextY))
    }
    
    func Count() -> Int
    {
        return Nodes.count
    }
    
    func Color(color: UIColor)
    {
        for node in Nodes
        {
            node.color = color
        }
    }
    
    func Contains(_ node: SKNode) -> Bool
    {
        for Node in Nodes
        {
            if(Node == node)
            {
                return true
            }
        }
        return false
    }
    
    func RemoveFromUI()
    {
        for node in Nodes
        {
            node.removeFromParent()
        }
    }
    
    func MoveToPoint(x: CGFloat, y: CGFloat)
    {
        for i in 0...Nodes.count-1
        {
            Nodes[i].position = CGPoint(x: 30*CGFloat(positions[i].0)+x, y: 30*CGFloat(positions[i].1)+y)
        }
        
        UIPosition = Nodes[0].position
    }
    
    func MoveToPoint(point: CGPoint)
    {
        MoveToPoint(x: point.x, y: point.y)
    }
    
    func GetUIPosition() -> CGPoint
    {
        return UIPosition
    }
    
    func GetNodes() -> Array<SKSpriteNode>
    {
        return Nodes
    }
    
    func SetZPosition(zpos: CGFloat)
    {
        for Node in Nodes
        {
            Node.zPosition = zpos
        }
    }
    
    func OverGrid(gridholder: SKSpriteNode) -> (Int,Int)?
    {
        let allowance:CGFloat = 210
        for node in Nodes
        {
            if((node.position.x < gridholder.position.x-allowance) || (node.position.x > gridholder.position.x+allowance) || (node.position.y < gridholder.position.y-allowance) || (node.position.y > gridholder.position.y+allowance))
            {
                return nil
            }
        }
        
        let pos = Nodes[0].position
        var xIndex = 6+Int(pos.x-gridholder.position.x+15)/30
        var yIndex = 6+Int(pos.y-gridholder.position.y+15)/30
        
        if(xIndex < -hbounds.0)
        {
            xIndex = -hbounds.0
        }
        else if(xIndex > 12-hbounds.1)
        {
            xIndex = 12-hbounds.1
        }
        if(yIndex < -vbounds.0)
        {
            yIndex = -vbounds.0
        }
        else if(yIndex > 12-vbounds.1)
        {
            yIndex = 12-vbounds.1
        }
        
        return (xIndex,yIndex)
    }
    
    func TryLock(indecies: (Int,Int), grid: Array<Array<BGCell?>?>) -> Bool
    {
        for i in 0...Nodes.count-1
        {
            let Pos = positions[i]
            if(grid[indecies.0+Pos.0]![indecies.1+Pos.1]!.Occupied())
            {
                GameScene.postDebug(text: String(indecies.0+Pos.0)+", "+String(indecies.1+Pos.1))
                return false
            }
        }
        // All positions free!
        for i in 0...Nodes.count-1
        {
            let Pos = positions[i]
            grid[indecies.0+Pos.0]![indecies.1+Pos.1]!.Accept(node: Nodes[i])
        }
        
        gamePosition = indecies
        return true
    }
    
    func Unlock(grid: Array<Array<BGCell?>?>)
    {
        if(gamePosition != nil)
        {
            for i in 0...Nodes.count-1
            {
                let Pos = positions[i]
                grid[gamePosition!.0+Pos.0]![gamePosition!.1+Pos.1]!.Clear()
            }
        }
    }
}
