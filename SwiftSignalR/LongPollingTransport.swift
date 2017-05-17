////
////  LongPollingTransport.swift
////  SwiftSignalR
////
////  Created by zsy on 2017/5/8.
////  Copyright © 2017年 zsy. All rights reserved.
////
//
//import Foundation
//open class LongPollingTransport:ClientBaseTransport{
//    open override func start(_ connection: IConnection, connectionData:String, disconnectToken: CancellationToken,completion:(Error?)->()){
//        fatalError("must override")
//    }
//    
//    open override func send(_ connection: IConnection, data:String, connectionData:String,completionHandler:((_ response:Any?,_ error:Error?)->())?){
//        fatalError("must override")
//        
//    }
//    
//    open override func lostConnection(_ connection: IConnection) {
//        fatalError("must override")
//    }
//
//}
