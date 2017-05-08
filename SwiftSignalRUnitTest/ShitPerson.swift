//
//  File.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/5/5.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
import SwiftSignalR
public class Shit: Jsonable{
    var shitColor:Int
    
    var shitShape:Int
    
    var shitWeight:Int
    
    init(shitColor:Int,shitShape:Int,shitWeight:Int){
        self.shitShape = shitShape
        self.shitColor = shitColor
        self.shitWeight = shitWeight
    }
    
    public func toJsonObject()->NSDictionary{
        let dic = NSMutableDictionary()
        dic["ShitColor"] = shitColor
        dic["ShitWeight"] = shitWeight
        dic["ShitShape"] = shitShape
        
        return dic
    }
}

public class ShitPerson: Jsonable{
    var gender:Int
    
    var age:Int
    
    var name: String
    
    var shits:[Shit]
    
    init(gender:Int,age:Int,name:String,shits:[Shit]){
        self.gender = gender
        self.age = age
        self.name = name
        self.shits = shits
    }
    public func toJsonObject()->NSDictionary{
        let dic = NSMutableDictionary()
        dic["Gender"] = gender
        dic["Age"] = age
        dic["Name"] = name
        dic["Shits"] = shits
        
        return dic
    }
    
}