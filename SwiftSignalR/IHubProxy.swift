//
//  IHubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IHubProxy:class {
    func on(method:String,action:([AnyObject?]?->()))-> Subscription?
    
    func invoke(method:String,params:[AnyObject?]?)
    
    func invoke(method:String,params:[AnyObject?]?,completionHandler:((response:Any?,error:ErrorType?)->())?)
    
    func invoke(method:String,onProgress:(Any?->())?,params:[AnyObject?]?,completionHandler:((response:Any?,error:ErrorType?)->())?)
         
}