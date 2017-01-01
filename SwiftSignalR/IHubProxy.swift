//
//  IHubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IHubProxy:class {
    func on(method:String,action:([Any]?->()))-> Subscription?
    
    func invoke(method:String,params: Any?...)
    
    func invoke(method:String,params:Any?,completionHandler:((reponse:Any?,error:ErrorType?)->())?)
    
    func invoke<T>(method:String,params:Any?...,completionHandler:((respones:T?,error:ErrorType?)->())?)
    
}