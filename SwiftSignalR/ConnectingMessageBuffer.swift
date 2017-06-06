//
//  ConnectingMessageBuffer.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/6/6.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
public class ConnectingMessageBuffer{
    private var buffer: [Any]
    private var connection: IConnection;
    private var drainCallback: (message:Any)->()
    private var bufferLock: SSRLock
    
    public init(connection:IConnection,drainCallback:(message:Any)->()){
        self.buffer = []
        self.connection = connection
        self.drainCallback = drainCallback
        self.bufferLock = SSRLock();
    }
    
    public func tryBuffer(message:Any)->Bool{
        var res:Bool = false
        
        if(connection.state == .Connecting){
            bufferLock.performLocked({
                self.buffer.append(message)
                res = true
            })
        }
        
        return res
    }
    
    public func drain(){
        if(connection.state == .Connected){
            bufferLock.performLocked({
                for message in self.buffer{
                    self.drainCallback(message: message)
                }
                self.buffer.removeAll()
            })
        }
    }
    
    public func clear(){
        bufferLock.performLocked({
            self.buffer.removeAll()
        })
    }
    
}