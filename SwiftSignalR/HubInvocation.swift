//
//  HubInvocation.swift
//  SwiftSignalR
//
//  Created by zsy on 17/1/1.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
open class HubInvocation: Jsonable{
    
    fileprivate static let callbackIdKey = "I"
    
    fileprivate static let hubKey = "H"
    
    fileprivate static let methodKey = "M"
    
    fileprivate static let argsKey = "A"
    
    fileprivate static let stateKey = "S"
    
    open var callbackId: String?
    
    open var hub: String
    
    open var method: String
    
    open var args: [AnyObject]? = nil
    
    open var state: [String:AnyObject]? = nil
    
    public init(callbackId:String?,hub:String,method:String,args:[AnyObject]? = nil,state:[String:AnyObject]? = nil){
        self.callbackId = callbackId
        self.hub = hub
        self.method = method
        self.args = args
        self.state = state
    }
    
    public init(parameters:[String:AnyObject]){

        self.callbackId = parameters[HubInvocation.callbackIdKey] as? String
        self.hub = parameters[HubInvocation.hubKey] as! String
        self.method = parameters[HubInvocation.methodKey] as! String
        if let argArr = parameters[HubInvocation.argsKey] as? [AnyObject]{
            self.args = argArr
        }
        if let stateDic = parameters[HubInvocation.stateKey] as? [String:AnyObject]{
            self.state = stateDic
        }
    }
    
    open func toJsonObject()-> NSDictionary{
        let dic = NSMutableDictionary()
        dic[HubInvocation.callbackIdKey] = self.callbackId
        dic[HubInvocation.hubKey] = self.hub
        dic[HubInvocation.methodKey] = self.method
        dic[HubInvocation.argsKey] = self.args
        dic[HubInvocation.stateKey] = self.state
        
        return dic
    }
    
}
