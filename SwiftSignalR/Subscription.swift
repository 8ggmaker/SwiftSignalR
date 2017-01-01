//
//  Subscription.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class Subscription{
    private var action : ([Any]?->())? = nil
    public func setAction(action:([Any]?->())?){
        self.action = action
    }
}