//
//  Subscription.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class Subscription{
    fileprivate var action : (([AnyObject?]?)->())? = nil
    open func setAction(_ action:@escaping (([AnyObject?]?)->())){
        self.action = action
    }
    
    open func executeAction(_ args:[AnyObject?]?){
        self.action!(args)
    }
}
