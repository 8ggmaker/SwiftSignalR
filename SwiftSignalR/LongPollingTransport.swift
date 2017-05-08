//
//  LongPollingTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/5/8.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
public class LongPollingTransport:ClientBaseTransport{
    public override func start(connection: IConnection, connectionData:String, disconnectToken: CancellationToken,completion:(ErrorType?)->()){
        fatalError("must override")
    }
    
    public override func send(connection: IConnection, data:String, connectionData:String,completionHandler:((response:Any?,error:ErrorType?)->())?){
        fatalError("must override")
        
    }
    
    public override func lostConnection(connection: IConnection) {
        fatalError("must override")
    }

}