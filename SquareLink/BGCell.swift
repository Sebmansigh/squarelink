//
//  File.swift
//  SquareLink
//
//  Created by Sebastian Snyder on 12/9/17.
//  Copyright © 2017 Sebastian Snyder. All rights reserved.
//

import Foundation
import SpriteKit

class BGCell
{
    var Node: SKSpriteNode
    var Occupant: SKSpriteNode?
    
    init(node: SKSpriteNode)
    {
        Node = node
        Occupant = nil
    }
    
    func Occupied() -> Bool
    {
        guard let _ : SKSpriteNode = Occupant else
        {
           return false
        }
        
        return true
    }
    
    func Accept(node: SKSpriteNode)
    {
        Occupant = node
    }
    
    func Clear()
    {
        Occupant = nil
    }
}
