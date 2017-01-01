//
//  TransportHelper.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
public class TransportHelper{
    
    
    public func getNegotiationResponse(httpClient:IHttpClient,connection:IConnection?,connectionData:String?) -> Promise<NegotiationResponse> {
        
        
        return Promise{
            fulfill,reject in
            
            if connection == nil{
                reject(CommonException.ArgumentNullException(exception: "connection"))
            }
            
            let negotiateUrl = try UrlBuilder.buildNegotiate(connection, connectionData: connectionData)
            
//            Alamofire.request(.GET, negotiateUrl).responseObject{
//                (response:Result<SSRNegotiationResponse,NSError>) in
//                if response.value != nil{
//                    fulfill(response.value!)
//                }else{
//                    reject(response.error!)
//                }
//            }
            httpClient.get(negotiateUrl,cancellationToken: nil,data: nil).then{
                res -> Void in
                let negotiationResp = NegotiationResponse(json: res)
                
                fulfill(negotiationResp)
                }.error{
                    err in
                    reject(err)
            }
        }
       
    }
    
    public func getStartResponse(httpClient:IHttpClient,connection:IConnection?,connectionData:String?,transport:String?)->Promise<String>{
        
        return Promise{
            fulfill, reject in
            if connection == nil{
                 reject(CommonException.ArgumentNullException(exception: "connection"))
            }
            
            let startUrl = try UrlBuilder.buildStart(connection, transport: transport, connectionData: connectionData!)
            
//            Alamofire.request(.GET, startUrl).responseString{
//                response in
//                if response.result.value != nil{
//                    fulfill(response.result.value!)
//                }else{
//                    reject(response.result.error!)
//                }
//            }
            httpClient.get(startUrl,cancellationToken: nil,data: nil).then{
                res in
                fulfill(res)
                }.error{
                    err in
                    reject(err)
            }
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