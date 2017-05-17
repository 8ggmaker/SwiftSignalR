//
//  HubConnection.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class HubConnection: Connection, IHubConnection{
    
    fileprivate var hubs: Dictionary<String,IHubProxy> = Dictionary<String,IHubProxy>()
    
    fileprivate var callbacks: Dictionary<String,((HubResult?)->())> = Dictionary<String,((HubResult?)->())>()
    
    fileprivate var callbackId: UInt64 = 0
    
    fileprivate let idIncrementLock: SSRLock = SSRLock()
    
    fileprivate let callbackLock: SSRLock = SSRLock()
    
    public convenience init (url:String)throws {
        try self.init(url: url,useDefault: true)
    }
    
    public init(url:String,useDefault:Bool)throws {
        try super.init(url: HubConnection.getUrl(url, useDefault: useDefault),queryString:"")
    }
    
    public convenience init(url:String,queryString:Dictionary<String,String>)throws {
        try self.init(url:url,queryString: queryString,useDefault: true)
    }
    
    public init(url:String,queryString:Dictionary<String,String>,useDefault:Bool)throws {
        try super.init(url: HubConnection.getUrl(url, useDefault: useDefault), queryString: HubConnection.createQueryString(queryString))
    }
    
    open func registerCallback(_ callback: @escaping (HubResult?)->())-> String?{
        
        if self.callbackId == UInt64.max{
            SSRLog.log(CommonException.invalidArgumentException(exception: "call back id reach\(UInt64.max)"), message: nil)
            return nil
        }
        
        callbackLock.performLocked({
            
            self.idIncrementLock.performLocked({// seems no need to lock this
                self.callbackId = self.callbackId + 1
            })
            
            self.callbacks[String(self.callbackId)] = callback
        })
        
        return String(callbackId)
    }
    
    
    open func removeCallback(_ callbackId:String){
        callbacks[callbackId] = nil
    }
    
    
    open func createHubProxy(_ hubName:String) ->IHubProxy?{
        if self.state != .disconnected{
            SSRLog.log(CommonException.invalidArgumentException(exception: "create hub proxy"), message: "can not create proxy after connection has been started")
            return nil
        }
        
        if hubs[hubName.lowercased()] == nil{
            let hub = HubProxy(name: hubName.lowercased(), connection: self)
            hubs[hubName.lowercased()] = hub
            
            return hub
        }
        
        return nil
    }
    
    fileprivate static func getUrl(_ url:String,useDefault:Bool)-> String{
        var resUrl = url
        if resUrl.characters.last != "/" {
            resUrl.append("/")
        }
        if useDefault == true{
            resUrl.append("signalr")
        }
        return resUrl
    }
    
    open func clearInvocationCallbacks(_ error:String?){
        var errorCallbacks: [((HubResult?)->())]! = nil
        callbackLock.performLocked({
            errorCallbacks = Array(self.callbacks.values)
            self.callbacks = Dictionary<String,((HubResult?)->())>()
        })
        for callback in errorCallbacks{
            let hubResult = HubResult()
            hubResult.error = error
            callback(hubResult)
        }
    }
    
    open override func onReceived(_ data: Any?) {
        
        if let dic = data as? [String:AnyObject]{
            
            if dic["P"] != nil{
                let hubResult = HubResult(parameters: dic)
                var callback:((HubResult)->())? = nil
                callbackLock.performLocked({
                    if hubResult.progressUpdate != nil && hubResult.progressUpdate?.id != nil && hubResult.progressUpdate!.id?.isEmpty == false{
                        if self.callbacks[(hubResult.progressUpdate?.id)!] != nil{
                            callback = self.callbacks[(hubResult.progressUpdate?.id)!]
                        }
                    }
                })
                if callback != nil{
                    callback!(hubResult)
                }
            }else if dic["I"] != nil{
                let hubResult = HubResult(parameters: dic)
                var callback: ((HubResult)->())? = nil
                callbackLock.performLocked({
                    if hubResult.id != nil && hubResult.id?.isEmpty == false{
                        if self.callbacks[hubResult.id!] != nil{
                            callback = self.callbacks[hubResult.id!]
                            self.callbacks[hubResult.id!] = nil
                        }
                    }
                })
                if callback != nil{
                    callback!(hubResult)
                }
            }else{
                let invocation = HubInvocation(parameters: dic)
                var hubProxy: HubProxy? = nil
                
                if hubs[invocation.hub.lowercased()] != nil{
                    hubProxy = hubs[invocation.hub.lowercased()] as? HubProxy
                    if invocation.state != nil{
                         hubProxy?.setState(invocation.state!)
                    }
                    var params: [AnyObject?]? = nil
                    if invocation.args != nil{
                        params = []
                        for arg in invocation.args!{
                            params?.append(arg)
                        }
                    }
                    hubProxy?.invokeEvent(invocation.method, args: params)
                }
                
            }
            
            super.onReceived(data)
        }
        
    }
    
    open override func onSending() -> String {
        var data = [AnyObject]()
        hubs.flatMap({
            key,val -> HubRegistrationData in
            return HubRegistrationData(name: key)
        }).map({
            registrationData -> Void in
            data.append(registrationData.prepareForJson())
        })
        do{
            return try self.JsonSerialize(data as AnyObject)!
        }catch{
            
        }
        return ""
    }
}
