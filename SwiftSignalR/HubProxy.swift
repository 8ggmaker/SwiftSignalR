//
//  HubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HubProxy:IHubProxy{
    
    private var state = [String:AnyObject]()
    
    private var subscriptions: Dictionary<String,Subscription> = Dictionary<String,Subscription>()
    
    private var name: String = ""
    
    private weak var connection:IHubConnection! = nil
    
    public init(name:String,connection:IHubConnection){
        self.name = name
        self.connection = connection
    }
    
    public func on(method:String,action:([AnyObject?]?->()))-> Subscription?{
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
    
    public func setState(dic:Dictionary<String,AnyObject>){
//        for (key,val) in dic{
//            state[key as! NSCopying] = val
//        }
        state = dic
    }
    
    public func invoke(method:String,params: [AnyObject?]?){
        self.invoke(method, params: params, completionHandler: nil)
    }
    
    public func invoke(method:String,params:[AnyObject?]?,completionHandler:((response:Any?,error:ErrorType?)->())?){
        self.invoke(method, onProgress: nil, params: params, completionHandler: completionHandler)
    }
    
    public func invoke(method:String,onProgress:(Any?->())?,params:[AnyObject?]?,completionHandler:((response:Any?,error:ErrorType?)->())?){
        var callbackId: String?
        if completionHandler != nil{
            callbackId = connection.registerCallback({
                res -> Void in
                if res?.error != nil{
                    let error = SwiftSignalRException.ServerOperationException(exception: (res?.error!)!, data: res?.errorData)
                    completionHandler!(response:nil,error:error)
                }else{
                    if res?.state != nil{
                        self.setState((res?.state)!)
                    }
                    
                    if res?.progressUpdate != nil &&  onProgress != nil{
                        onProgress!(res?.progressUpdate!.data)
                    }else{
                        completionHandler!(response:res?.result,error:nil)
                    }
                }
            })
            if callbackId == nil || (callbackId?.isEmpty)! {
                completionHandler!(response:nil,error:CommonException.InvalidOperationException(exception: "register invoke call back failed"))
                return
            }
            
        }
        do{
            var validParams: [AnyObject]? = nil
            if params != nil{
                validParams = []
                for param in params! {
                    if param == nil{
                        validParams?.append(NSNull())
                    }else{
                        validParams?.append(param!)
                    }
                }
            }
            
            let hubInvocationData  = HubInvocation(callbackId:callbackId,hub:name,method:method,args:validParams,state:state)
            
            let val = try connection.JsonSerialize(hubInvocationData)
            
            connection.send(val!, completionHandler: nil)
            
        }catch let err{
            SSRLog.log(err, message: "can not serialize invoke params")
            if completionHandler != nil{
                completionHandler!(response:nil,error:err)
            }
        }
        
        
    }

    
    public func invokeEvent(eventName:String,args:[AnyObject?]?){
        if subscriptions[eventName.lowercaseString] != nil{
            let subscription = subscriptions[eventName.lowercaseString]
            subscription?.executeAction(args)
        }
    }
}