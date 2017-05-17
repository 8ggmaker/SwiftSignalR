//
//  IConnection.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IConnection:class{
    var clientProtocol: Version{
        get
        set
    }
    
    var transportConnectTimeout: TimeInterval{
        get
        set
    }
    
    var totalTransportConnectTimeout: TimeInterval{
        get
    }
    
    var reconnectWindow: TimeInterval{
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
    
    var lastMessageAt: Date{
        get
    }
    
    
    var lastActiveAt: Date{
        get
    }
    
    var headers: NSMutableDictionary{
        get
    }
    
    var credentials: URLCredential{
        get
        set
    }
    
    func changeState(_ oldState:ConnectionState,newState:ConnectionState) -> Bool
    
    func stop()
    
    func disconnect()
    
    func send(_ data:String, completionHandler:((_ response:Any?,_ error:Error?)->())?)
    
    func onReceived(_ data: Any?)
    
    func onError(_ error:Error)
    
    func onReconnecting()
    
    func onReconnected()
    
    func onConnectionSlow()
    
    func markLastMessage()
    
    func markActive()
    
    func prepareRequest(_ request:URLRequest)-> URLRequest
    
    var JsonDeSerialize: ((String)throws -> AnyObject? ){
        get
        set
    }
    var JsonSerialize: ((AnyObject)throws -> String?){
        get
        set
    }
    
}
