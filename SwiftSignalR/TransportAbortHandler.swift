//
//  TransportAbortHandler.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/25.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
open class TransportAbortHandler{
    
    fileprivate var transportName:String
    
    fileprivate var startedAbort: Bool
    
    fileprivate var abortqueue : DispatchQueue
    
    public init(transportName:String){
        
        self.transportName = transportName
        
        abortqueue = DispatchQueue(label: "TransportAbortHandler.Abortqueue", attributes: [])
        
        startedAbort = false
    }
    
    open func abort(_ connection:IConnection?,timeout:TimeInterval,connectionData:String)throws {
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        abortqueue.sync{
            if !self.startedAbort{
                self.startedAbort = true
                
                do{
                    let url = try UrlBuilder.buildAbort(connection, transport: self.transportName, connectionData: connectionData)
                    var request = URLRequest(url: URL(string: url)!)
                    request.timeoutInterval = timeout
                    let swiftRequest = Alamofire.SessionManager.default.request((connection?.prepareRequest(request))! as URLRequestConvertible)
                    
                    swiftRequest.responseData(){
                        response in
                        if response.result.error != nil{
                            self.completeAbort()
                        }
                        
                    }
                    
                }
                catch{
                    self.completeAbort() 
                }
                
            }
        }
    }
    
    open func completeAbort(){
        startedAbort = true
    }
    
    open func TryCompleteAbort()-> Bool{
    
        return startedAbort
    }
    
}
