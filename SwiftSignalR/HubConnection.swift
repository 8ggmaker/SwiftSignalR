//
//  HubConnection.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HubConnection: Connection, IHubConnection{
    
    private var hubs: Dictionary<String,IHubProxy> = Dictionary<String,IHubProxy>()
    
    private var callbacks: Dictionary<String,(HubResult?->())> = Dictionary<String,(HubResult?->())>()
    
    private var callbackId: Int64 = 0
    
    private let idIncrementLock: SSRLock = SSRLock()
    
    private let callbackLock: SSRLock = SSRLock()
    
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
    
    public func registerCallback(callback: (HubResult?->()))-> String?{
        
        callbackLock.performLocked({
            self.idIncrementLock.performLocked({// seems no need to lock this
                self.callbackId = self.callbackId + 1
            })
            
            self.callbacks[String(self.callbackId)] = callback
        })
        
        return String(callbackId)
    }
    
    
    public func removeCallback(callbackId:String){
        callbacks[callbackId] = nil
    }
    
    
    public func createHubProxy(hubName:String) ->IHubProxy?{
        if self.state != .Disconnected{
            SSRLog.log(CommonException.InvalidArgumentException(exception: "create hub proxy"), message: "can not create proxy after connection has been started")
            return nil
        }
        
        if hubs[hubName.lowercaseString] == nil{
            let hub = HubProxy(name: hubName.lowercaseString, connection: self)
            hubs[hubName.lowercaseString] = hub
            
            return hub
        }
        
        return nil
    }
    
    private static func getUrl(url:String,useDefault:Bool)-> String{
        var resUrl = url
        if resUrl.characters.last != "/" {
            resUrl.appendContentsOf("/")
        }
        if useDefault == true{
            resUrl.appendContentsOf("signalr")
        }
        return resUrl
    }
    
    public func clearInvocationCallbacks(error:String?){
        var errorCallbacks: [(HubResult?->())]! = nil
        callbackLock.performLocked({
            errorCallbacks = Array(self.callbacks.values)
            self.callbacks = Dictionary<String,(HubResult?->())>()
        })
        for callback in errorCallbacks{
            let hubResult = HubResult()
            hubResult.error = error
            callback(hubResult)
        }
    }
    
    public override func onReceived(data: Any?) {
        
        if data is NSMutableDictionary{
            let dic = data as! NSMutableDictionary
            
            if dic["P"] != nil{
                let hubResult = HubResult(parameters: dic)
                var callback:(HubResult->())? = nil
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
                var callback: (HubResult->())? = nil
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
                
                if invocation.hub != nil && hubs[invocation.hub!.lowercaseString] != nil{
                    hubProxy = hubs[invocation.hub!.lowercaseString] as? HubProxy
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
                    hubProxy?.invokeEvent(invocation.method!, args: params)
                }
                
            }
            
            super.onReceived(data)
        }
        
    }
    
    public override func onSending() -> String {
        let data = NSMutableArray()
        hubs.flatMap({
            key,val -> HubRegistrationData in
            return HubRegistrationData(name: key)
        }).map({
            registrationData -> Void in
            data.addObject(registrationData.prepareForJson())
        })
        do{
            return try self.JsonSerialize(data)!
        }catch{
            
        }
        return ""
    }
}