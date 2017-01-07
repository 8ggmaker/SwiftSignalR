//
//  IClientTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import PromiseKit
public protocol IClientTransport{
    
    var name:String{get}
    
    var supportKeepAlive: Bool{get}
    
    func negotiate(connection: IConnection, connectionData: String)-> Promise<NegotiationResponse>
    
    func start(connection: IConnection, connectionData:String, disconnectToken: CancellationToken)throws-> Promise<Void>
    
    func send(connection: IConnection, data:String, connectionData:String,completionHandler:((response:Any?,error:ErrorType?)->())?)
    
    func abort(connection: IConnection, timeout:NSTimeInterval,connectionData:String) throws
    
    func lostConnection(connection:IConnection)
    
}