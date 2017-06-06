//
//  TransportAbortHandler.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/25.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
public class TransportAbortHandler{
    
    private var transportName:String
    
    private var startedAbort: Bool
    
    private var abortqueue : dispatch_queue_t
    
    public init(transportName:String){
        
        self.transportName = transportName
        
        abortqueue = dispatch_queue_create("TransportAbortHandler.Abortqueue", DISPATCH_QUEUE_SERIAL)
        
        startedAbort = false
    }
    
    public func abort(connection:IConnection?,timeout:NSTimeInterval,connectionData:String)throws {
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        dispatch_sync(abortqueue){
            if connection == nil{
                return
            }
            if !self.startedAbort{
                self.startedAbort = true
                
                do{
                    let url = try UrlBuilder.buildAbort(connection, transport: self.transportName, connectionData: connectionData)
                    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                    request.timeoutInterval = timeout
                    let swiftRequest = Alamofire.Manager.sharedInstance.request((connection?.prepareRequest(request))!)
                    
                    swiftRequest.responseData(){
                       [weak self] response in
                        if response.result.error != nil && self != nil{
                            self!.completeAbort()
                        }
                        
                    }
                    
                }
                catch{
                    self.completeAbort() 
                }
                
            }
        }
    }
    
    public func completeAbort(){
        startedAbort = true
    }
    
    public func TryCompleteAbort()-> Bool{
    
        return startedAbort
    }
    
}