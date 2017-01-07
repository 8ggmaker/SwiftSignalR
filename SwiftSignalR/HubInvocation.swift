//
//  HubInvocation.swift
//  SwiftSignalR
//
//  Created by zsy on 17/1/1.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
public class HubInvocation{
    
    private static let callbackIdKey = "I"
    
    private static let hubKey = "H"
    
    private static let methodKey = "M"
    
    private static let argsKey = "A"
    
    private static let stateKey = "S"
    
    public var callbackId: String? = nil
    
    public var hub: String? = nil
    
    public var method: String? = nil
    
    public var args: NSMutableArray? = nil
    
    public var state: NSMutableDictionary? = nil
    
    
    public init(){
        
    }
    
    public init(parameters:NSMutableDictionary){
        
        if parameters[HubInvocation.callbackIdKey] != nil && parameters[HubInvocation.callbackIdKey] is String{
            self.callbackId = parameters[HubInvocation.callbackIdKey] as? String
        }
        if parameters[HubInvocation.hubKey] != nil && parameters[HubInvocation.hubKey] is String{
            self.hub = parameters[HubInvocation.hubKey] as? String
        }
        if parameters[HubInvocation.methodKey] != nil && parameters[HubInvocation.methodKey] is String{
            self.method = parameters[HubInvocation.methodKey] as? String
        }
        if parameters[HubInvocation.argsKey] != nil && parameters[HubInvocation.argsKey] is NSArray{
            self.args = NSMutableArray(array: (parameters[HubInvocation.argsKey] as? NSArray)!)
        }
        if parameters[HubInvocation.stateKey] != nil && parameters[HubInvocation.stateKey] is NSDictionary{
            self.state = NSMutableDictionary(dictionary: (parameters[HubInvocation.stateKey] as? NSDictionary)!)
        }
    }
    
    public func prepareForJson()-> NSMutableDictionary{
        let dic = NSMutableDictionary()
        dic[HubInvocation.callbackIdKey] = self.callbackId
        dic[HubInvocation.hubKey] = self.hub
        dic[HubInvocation.methodKey] = self.method
        dic[HubInvocation.argsKey] = self.args
        dic[HubInvocation.stateKey] = self.state
        
        return dic
    }
    
}