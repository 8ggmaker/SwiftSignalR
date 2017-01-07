//
//  IConnection.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import PromiseKit
public protocol IConnection:class{
    var clientProtocol: Version{
        get
        set
    }
    
    var transportConnectTimeout: NSTimeInterval{
        get
        set
    }
    
    var totalTransportConnectTimeout: NSTimeInterval{
        get
    }
    
    var reconnectWindow: NSTimeInterval{
        get
        set
    }
    
    var keepAliveData: KeepAliveData?{
        get
        set
    }
    
    var messageId:String? {
        get
        set
    }
    
    var groupsToken:String? {
        get
        set
    }
    
    var items:NSMutableDictionary{
        get
    }
    
    var connectionId: String{
        get
    }
    
    var connectionToken: String? {
        get
    }
    
    var url: String{
        get
    }
    
    var queryString: String? {
        get
    }
    
    var state: ConnectionState{
        get
    }
    
    var transport: IClientTransport!{
        get
    }
    
    var lastMessageAt: NSDate{
        get
    }
    
    
    var lastActiveAt: NSDate{
        get
    }
    
    var headers: NSMutableDictionary{
        get
    }
    
    var credentials: NSURLCredential{
        get
        set
    }
    
    func changeState(oldState:ConnectionState,newState:ConnectionState) -> Bool
    
    func stop()
    
    func disconnect()
    
    func send(data:String, completionHandler:((response:Any?,error:ErrorType?)->())?)
    
    func onReceived(data: Any?)
    
    func onError(error:ErrorType)
    
    func onReconnecting()
    
    func onReconnected()
    
    func onConnectionSlow()
    
    func markLastMessage()
    
    func markActive()
    
    func prepareRequest(request:NSMutableURLRequest)-> NSMutableURLRequest
    
    var JsonDeSerialize: ((String)throws -> AnyObject? ){
        get
        set
    }
    var JsonSerialize: ((AnyObject)throws -> String?){
        get
        set
    }
    
}