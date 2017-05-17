//
//  ClientTransportBase.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/17.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import UIKit

open class TransportConnectionInfo{
    var connection: IConnection!
    var connectionData:String!
    var disconnectToken: CancellationToken!
    
    init(connection:IConnection,connectionData:String,disconnectToken:CancellationToken){
        self.connection = connection
        self.connectionData = connectionData
        self.disconnectToken = disconnectToken
    }
}

open class ClientBaseTransport: NSObject,IClientTransport{
    
    
    fileprivate var transportName:String
    
    final var abortHandler: TransportAbortHandler
    
    final var transportHelper: TransportHelper
    
    final var httpClient: IHttpClient
    
    final var finished: Bool = false

    final var connectionInfo: TransportConnectionInfo! = nil
        
    final var connected:Bool = false
    
    final var completion:((Error?)->())? = nil


    public init(name:String,httpClient:IHttpClient){
        self.transportName = name
        self.httpClient = httpClient
        self.transportHelper = TransportHelper()
        self.abortHandler = TransportAbortHandler(transportName: transportName)
    }
    
    open var name:String{
        get{
            return transportName
        }
    }
    
    open var supportKeepAlive: Bool{
        get{
            fatalError("must override")
        }
    }

    open func negotiate(_ connection: IConnection, connectionData: String, completion:@escaping (Error?,NegotiationResponse?)->()){
         return transportHelper.getNegotiationResponse(self.httpClient,connection:connection,connectionData: connectionData,completion: completion)
    }

    open func initRecived(_ connection:IConnection,connectionData:String,completion:@escaping (Error?,String?)->()){
        return transportHelper.getStartResponse(httpClient, connection: connection, connectionData: connectionData, transport: transportName,completion:completion)
    }
    
    open func start(_ connection: IConnection, connectionData:String, disconnectToken: CancellationToken,completion:@escaping (Error?)->()){
        fatalError("must override")
    }
    
    open func send(_ connection: IConnection, data:String, connectionData:String,completionHandler:((_ response:Any?,_ error:Error?)->())?){
        fatalError("must override")

    }
    
    open func abort(_ connection: IConnection, timeout:TimeInterval,connectionData:String) throws{
        do{
            try abortHandler.abort(connection, timeout: timeout, connectionData: connectionData)
        }catch let err{
            
        }
    }
    
    open func lostConnection(_ connection:IConnection){
        fatalError("must override")
    }
    
    
    open func processResponse(_ connection:IConnection,message:String)-> Bool{
         connection.markLastMessage()
        
        if message.isEmpty {
            return false
        }
        
        var shouldReconnect = false
        
        do{
            if let res = try connection.JsonDeSerialize(message) as? [String:AnyObject]{
                if res["I"] != nil{
                    connection.onReceived(res)
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
                    connection.onReceived(msg)
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
    
    
     func initialize(_ connection:IConnection,connectionData:String,disconnectToken:CancellationToken){
        self.connectionInfo = TransportConnectionInfo(connection: connection, connectionData: connectionData, disconnectToken: disconnectToken)
    }
    
    func doCompletionCallback(_ err:Error?){
        self.completion?(err)
        self.completion = nil
    }

}
