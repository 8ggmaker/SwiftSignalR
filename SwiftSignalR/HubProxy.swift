//
//  HubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class HubProxy:IHubProxy{
    
    fileprivate var state = [String:AnyObject]()
    
    fileprivate var subscriptions: Dictionary<String,Subscription> = Dictionary<String,Subscription>()
    
    fileprivate var name: String = ""
    
    fileprivate weak var connection:IHubConnection! = nil
    
    public init(name:String,connection:IHubConnection){
        self.name = name
        self.connection = connection
    }
    
    open func on(_ method:String,action:@escaping ([AnyObject?]?)->())-> Subscription?{
        if method.isEmpty{
            SSRLog.log(CommonException.argumentNullException(exception: "method"), message: "hubproxy on event, method is nil or empty")
            return nil
        }
        
        let lowcaseMethodStr = method.lowercased()
        if subscriptions[lowcaseMethodStr] == nil{
            let subscription = Subscription()
            subscription.setAction(action)
            subscriptions[lowcaseMethodStr] = subscription
            
            return subscription
        }
        
        SSRLog.log(nil, message: "subscription to event \(method) already exist")
        return nil
    }
    
    open func setState(_ dic:Dictionary<String,AnyObject>){
//        for (key,val) in dic{
//            state[key as! NSCopying] = val
//        }
        state = dic
    }
    
    open func invoke(_ method:String,params: [AnyObject?]?){
        self.invoke(method, params: params, completionHandler: nil)
    }
    
    open func invoke(_ method:String,params:[AnyObject?]?,completionHandler:((_ response:Any?,_ error:Error?)->())?){
        self.invoke(method, onProgress: nil, params: params, completionHandler: completionHandler)
    }
    
    open func invoke(_ method:String,onProgress:((Any?)->())?,params:[AnyObject?]?,completionHandler:((_ response:Any?,_ error:Error?)->())?){
        var callbackId: String?
        if completionHandler != nil{
            callbackId = connection.registerCallback({
                res -> Void in
                if res?.error != nil{
                    let error = SwiftSignalRException.serverOperationException(exception: (res?.error!)!, data: res?.errorData)
                    completionHandler!(nil,error)
                }else{
                    if res?.state != nil{
                        self.setState((res?.state)!)
                    }
                    
                    if res?.progressUpdate != nil &&  onProgress != nil{
                        onProgress!(res?.progressUpdate!.data)
                    }else{
                        completionHandler!(res?.result,nil)
                    }
                }
            })
            if callbackId == nil || (callbackId?.isEmpty)! {
                completionHandler!(nil,CommonException.invalidOperationException(exception: "register invoke call back failed"))
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
                completionHandler!(nil,err)
            }
        }
        
        
    }

    
    open func invokeEvent(_ eventName:String,args:[AnyObject?]?){
        if subscriptions[eventName.lowercased()] != nil{
            let subscription = subscriptions[eventName.lowercased()]
            subscription?.executeAction(args)
        }
    }
}
