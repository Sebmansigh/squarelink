//
//  Stack.swift
//  SquareLink
//
//  Created by Sebastian Snyder on 12/9/17.
//  Copyright © 2017 Sebastian Snyder. All rights reserved.
//

import Foundation

class Stack<T>
{
    private var Data : Array<Any> = [];
    var count : Int = 0;
    
    func Push(data: T)
    {
        Data = [data, Data]
        count += 1
    }
    
    func PopTry() -> T?
    {
        if(count == 0)
        {
            return nil
        }
        else
        {
            let ret = Data[0]
            Data = Data[1] as! Array<Any>
            count -= 1
            return ret as? T
        }
    }
    
    func PopForce() -> T
    {
        if(count == 0)
        {
            count = 0 / Int("0")!
        }
        let ret = Data[0]
        Data = Data[1] as! Array<Any>
        count -= 1
        return ret as! T
    }
    
    
}
