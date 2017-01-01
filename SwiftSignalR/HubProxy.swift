//
//  HubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HubProxy:IHubProxy{
    
    private let state: NSMutableDictionary = NSMutableDictionary()
    
    private var subscriptions: Dictionary<String,Subscription> = Dictionary<String,Subscription>()
    
    private var name: String = ""
    
    private weak var connection:IHubConnection! = nil
    
    public init(name:String,connection:IHubConnection){
        self.name = name
        self.connection = connection
    }
    
    public func on(method:String,action:([Any]?->()))-> Subscription?{
        if method.isEmpty{
            SSRLog.log(CommonException.ArgumentNullException(exception: "method"), message: "hubproxy on event, method is nil or empty")
            return nil
        }
        
        let lowcaseMethodStr = method.lowercaseString
        if subscriptions[lowcaseMethodStr] == nil{
            let subscription = Subscription()
            subscription.setAction(action)
            subscriptions[lowcaseMethodStr] = subscription
            
            return subscription
        }
        
        SSRLog.log(nil, message: "subscription to event \(method) already exist")
        return nil
    }
    
    public func invoke(method:String,params: Any?...){
        
    }
    
    public func invoke(method:String,params:Any?,completionHandler:((reponse:Any?,error:ErrorType?)->())?){
        
    }
    
    public func invoke<T>(method:String,params:Any?...,completionHandler:((respones:T?,error:ErrorType?)->())?){
        
    }
}