//
//  ClientTransportBase.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/17.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import UIKit

public class TransportConnectionInfo{
    var connection: IConnection!
    var connectionData:String!
    var disconnectToken: CancellationToken!
    
    init(connection:IConnection,connectionData:String,disconnectToken:CancellationToken){
        self.connection = connection
        self.connectionData = connectionData
        self.disconnectToken = disconnectToken
    }
}

public class ClientBaseTransport: NSObject,IClientTransport{
    
    
    private var transportName:String
    
    final var abortHandler: TransportAbortHandler
    
    final var transportHelper: TransportHelper
    
    final var httpClient: IHttpClient
    
    final var finished: Bool = false

    final var connectionInfo: TransportConnectionInfo! = nil
        
    final var connected:Bool = false
    
    final var completion:(ErrorType?->())? = nil


    public init(name:String,httpClient:IHttpClient){
        self.transportName = name
        self.httpClient = httpClient
        self.transportHelper = TransportHelper()
        self.abortHandler = TransportAbortHandler(transportName: transportName)
    }
    
    public var name:String{
        get{
            return transportName
        }
    }
    
    public var supportKeepAlive: Bool{
        get{
            fatalError("must override")
        }
    }

    public func negotiate(connection: IConnection, connectionData: String, completion:(ErrorType?,NegotiationResponse?)->()){
         return transportHelper.getNegotiationResponse(self.httpClient,connection:connection,connectionData: connectionData,completion: completion)
    }

    public func initRecived(connection:IConnection,connectionData:String,completion:(ErrorType?,String?)->()){
        return transportHelper.getStartResponse(httpClient, connection: connection, connectionData: connectionData, transport: transportName,completion:completion)
    }
    
    public func start(connection: IConnection, connectionData:String, disconnectToken: CancellationToken,completion:(ErrorType?)->()){
        fatalError("must override")
    }
    
    public func send(connection: IConnection, data:String, connectionData:String,completionHandler:((response:Any?,error:ErrorType?)->())?){
        fatalError("must override")

    }
    
    public func abort(connection: IConnection, timeout:NSTimeInterval,connectionData:String) throws{
        try abortHandler.abort(connection, timeout: timeout, connectionData: connectionData)
    }
    
    public func lostConnection(connection:IConnection){
        fatalError("must override")
    }
    
    
    public func processResponse(connection:IConnection,message:String)-> Bool{
         connection.markLastMessage()
        
        if message.isEmpty {
            return false
        }
        
        var shouldReconnect = false
        
        do{
            if let res = try connection.JsonDeSerialize(message) as? [String:AnyObject]{
                if res["I"] != nil{
                    if !connection.connectingMessageBuffer.tryBuffer(message){
                        connection.onReceived(res)
                    }
                    return false
                }
                
                if res["T"] != nil && res["T"] as? String == "1"{
                    shouldReconnect = true
                }
                
                if let groupsToken = res["G"] as? String{
                    connection.groupsToken = groupsToken
                }
                
                guard let messages = res["M"] as? NSArray else{
                    return shouldReconnect
                }
                
                connection.messageId = res["C"] as? String
                
                for msg in messages{
                    if !connection.connectingMessageBuffer.tryBuffer(msg){
                        connection.onReceived(msg)
                    }
                }
                
                if res["S"] as? Int == 1{
                    self.initRecived(connection, connectionData: connectionInfo.connectionData){
                        _ -> Void in
                        self.connected = true
                        self.doCompletionCallback(nil)
                    }
                }
            }
            
        }catch let err{
            SSRLog.log(err, message: message)
        }
        
        return shouldReconnect
    }
    
    
     func initialize(connection:IConnection,connectionData:String,disconnectToken:CancellationToken){
        self.connectionInfo = TransportConnectionInfo(connection: connection, connectionData: connectionData, disconnectToken: disconnectToken)
    }
    
    func doCompletionCallback(err:ErrorType?){
        self.completion?(err)
        self.completion = nil
    }

}