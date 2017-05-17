//
//  TransportHelper.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

open class TransportHelper{
    
    
    open func getNegotiationResponse(_ httpClient:IHttpClient,connection:IConnection?,connectionData:String?,completion:@escaping (Error?,NegotiationResponse?)->()){
        
        if connection == nil{
            completion(CommonException.argumentNullException(exception: "connection"),nil)
            return
        }
        do{
            let negotiateUrl = try UrlBuilder.buildNegotiate(connection, connectionData: connectionData)
            httpClient.get(negotiateUrl,cancellationToken: nil){
                err,val -> Void in
                var negotiationResp: NegotiationResponse? = nil
                do{
                    if val != nil{
                        if let json = try connection?.JsonDeSerialize(val!){
                            if let parameters = json as? [String:Any]{
                                negotiationResp = NegotiationResponse(parameters: parameters)
                            }
                        }
                    }
                    
                    completion(err,negotiationResp)
                }catch let deserializeErr{
                    completion(deserializeErr,negotiationResp)
                }
   
            }

        }catch let err{
            completion(err,nil)
        }
        
        
        
    }
    
    open func getStartResponse(_ httpClient:IHttpClient,connection:IConnection?,connectionData:String?,transport:String?,completion:@escaping (Error?,String?)->()){
        
        if connection == nil{
            completion(CommonException.argumentNullException(exception: "connection"),nil)
            return
        }
        
        do{
            let startUrl = try UrlBuilder.buildStart(connection, transport: transport, connectionData: connectionData!)
            
            httpClient.get(startUrl,cancellationToken: nil){
                err,val in
                
                completion(err,val)
            }
            
        }catch let err{
            completion(err,nil)
        }
        
        
        
    }
    
    open static func verifyLastActive(_ conneciton:IConnection?) throws -> Bool{
        if conneciton == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        let curDate = Date()
        if curDate.timeIntervalSince((conneciton?.lastActiveAt)! as Date) >= conneciton?.reconnectWindow{
            conneciton?.stop()
            return false
        }
        return true
    }
}
