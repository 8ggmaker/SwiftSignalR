//
//  Subscription.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class Subscription{
    private var action : ([AnyObject?]?->())? = nil
    public func setAction(action:([AnyObject?]?->())){
        self.action = action
    }
    
    public func executeAction(args:[AnyObject?]?){
        self.action!(args)
    }
}