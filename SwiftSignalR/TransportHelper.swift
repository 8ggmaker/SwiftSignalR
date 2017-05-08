//
//  TransportHelper.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
public class TransportHelper{
    
    
    public func getNegotiationResponse(httpClient:IHttpClient,connection:IConnection?,connectionData:String?,completion:(ErrorType?,NegotiationResponse?)->()){
        
        if connection == nil{
            completion(CommonException.ArgumentNullException(exception: "connection"),nil)
            return
        }
        do{
            let negotiateUrl = try UrlBuilder.buildNegotiate(connection, connectionData: connectionData)
            httpClient.get(negotiateUrl,cancellationToken: nil,data: nil){
                err,val -> Void in
                var negotiationResp: NegotiationResponse? = nil
                if val != nil{
                    negotiationResp = NegotiationResponse(json:val)
                }
                
                completion(err,negotiationResp)
                
            }

        }catch let err{
            completion(err,nil)
        }
        
        
        
    }
    
    public func getStartResponse(httpClient:IHttpClient,connection:IConnection?,connectionData:String?,transport:String?,completion:(ErrorType?,String?)->()){
        
        if connection == nil{
            completion(CommonException.ArgumentNullException(exception: "connection"),nil)
            return
        }
        
        do{
            let startUrl = try UrlBuilder.buildStart(connection, transport: transport, connectionData: connectionData!)
            
            httpClient.get(startUrl,cancellationToken: nil,data: nil){
                err,val in
                
                completion(err,val)
            }
            
        }catch let err{
            completion(err,nil)
        }
        
        
        
    }
    
    public static func verifyLastActive(conneciton:IConnection?) throws -> Bool{
        if conneciton == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        let curDate = NSDate()
        if curDate.timeIntervalSinceDate((conneciton?.lastActiveAt)!) >= conneciton?.reconnectWindow{
            conneciton?.stop()
            return false
        }
        return true
    }
}