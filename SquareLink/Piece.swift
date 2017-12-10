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
    private var Nodes: Array<SKSpriteNode>
    private var positions: Array<(Int,Int)>
    private var gamePosition: (Int,Int)?
    private var UIPosition: CGPoint
    
    init(baseNode: SKSpriteNode)
    {
        Nodes = [baseNode]
        positions = [(0,0)]
        gamePosition = nil
        UIPosition = CGPoint(x:0,y:0)
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
}
