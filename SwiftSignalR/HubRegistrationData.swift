//
//  HubRegistrationData.swift
//  SwiftSignalR
//
//  Created by zsy on 17/1/1.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
open class HubRegistrationData{
    
    fileprivate static let hubNameKey = "Name"
    
    open var hubName:String? = nil
    
    public init(name:String){
        self.hubName = name
    }
    
    
    open func prepareForJson()-> NSMutableDictionary{
        let dic = NSMutableDictionary()
        dic[HubRegistrationData.hubNameKey] = hubName
        
        return dic
    }
}
