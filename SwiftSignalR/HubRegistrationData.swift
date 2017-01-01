//
//  HubRegistrationData.swift
//  SwiftSignalR
//
//  Created by zsy on 17/1/1.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
public class HubRegistrationData{
    
    private static let hubNameKey = "Name"
    
    public var hubName:String? = nil
    
    public init(name:String){
        self.hubName = name
    }
    
    
    public func prepareForJson()-> NSMutableDictionary{
        let dic = NSMutableDictionary()
        dic[HubRegistrationData.hubNameKey] = hubName
        
        return dic
    }
}