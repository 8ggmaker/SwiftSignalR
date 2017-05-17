//
//  IClientTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IClientTransport{
    
    var name:String{get}
    
    var supportKeepAlive: Bool{get}
    
    func negotiate(_ connection: IConnection, connectionData: String,completion:@escaping (Error?,NegotiationResponse?)->())
    
    func start(_ connection: IConnection, connectionData:String, disconnectToken: CancellationToken,completion:@escaping (Error?)->())
    
    func send(_ connection: IConnection, data:String, connectionData:String,completionHandler:((_ response:Any?,_ error:Error?)->())?)
    
    func abort(_ connection: IConnection, timeout:TimeInterval,connectionData:String) throws
    
    func lostConnection(_ connection:IConnection)
    
}
