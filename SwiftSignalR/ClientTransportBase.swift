//
//  ClientTransportBase.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/17.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

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

public class TransportStartPromiseWapper<T> {
    let (promise,fulfillHodler,rejectHoder) = Promise<T>.pendingPromise()
    
    var retainCycle: AnyObject? = nil
    
    public func fulfill(t:T)->Void{
        fulfillHodler(t)
        retainCycle = nil
    }
    
    public func reject(e:ErrorType)-> Void{
        rejectHoder(e)
        retainCycle = nil
    }
}

public class ClientBaseTransport: NSObject,IClientTransport{
    
    
    private var transportName:String
    
    final var abortHandler: TransportAbortHandler
    
    final var transportHelper: TransportHelper
    
    final var httpClient: IHttpClient
    
    final var finished: Bool = false

    final var connectionInfo: TransportConnectionInfo! = nil
    
    final var startPromiseWrapper: TransportStartPromiseWapper<Void>! = nil
    
    final var connected:Bool = false


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

    public func negotiate(connection: IConnection, connectionData: String)-> Promise<NegotiationResponse>{
         return transportHelper.getNegotiationResponse(self.httpClient,connection:connection,connectionData: connectionData)
    }

    public func initRecived(connection:IConnection,connectionData:String) -> Promise<String>{
        return transportHelper.getStartResponse(httpClient, connection: connection, connectionData: connectionData, transport: transportName)
    }
    
    public func start(connection: IConnection, connectionData:String, disconnectToken: CancellationToken)throws -> Promise<Void>{
        fatalError("must override")
    }
    
    public func send(connection: IConnection, data:String, connectionData:String,completionHandler:(response:Any?,error:ErrorType?)->Void){
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
            let res = try connection.JsonDeSerialize(message)
            if res is NSDictionary == true{
                let resDic = res as! NSDictionary
                if resDic["I"] != nil{
                    connection.onReceived(resDic)
                    return false
                }
                
                if resDic["T"] != nil && (resDic["T"] as! String) == "1"{
                    shouldReconnect = true
                }
                
                if let groupsToken = resDic["G"]{
                    connection.groupsToken = (groupsToken as! String)
                }
                
                guard let messages = resDic["M"] as? NSArray else{
                    return shouldReconnect
                }
                
                connection.messageId = resDic["C"] as? String
                
                for msg in messages {
                    connection.onReceived(msg)
                }
                
                if resDic["S"] != nil && (resDic["S"] as? Int) == 1{
                    self.initRecived(connection, connectionData: connectionInfo.connectionData).then{
                        _ -> Void in
                        self.connected = true
                        self.startPromiseWrapper.fulfill()
                    }
                }
                
            }
        }catch{
            
        }
        
        return shouldReconnect
    }
    
    
     func initialize(connection:IConnection,connectionData:String,disconnectToken:CancellationToken){
        self.connectionInfo = TransportConnectionInfo(connection: connection, connectionData: connectionData, disconnectToken: disconnectToken)
    }

}