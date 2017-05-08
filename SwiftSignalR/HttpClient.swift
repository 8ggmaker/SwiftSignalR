//
//  HttpClient.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/19.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
public class HttpClient: IHttpClient{
    
    private var requestManager: Alamofire.Manager
    
    public init(){
        self.requestManager = Alamofire.Manager(configuration:NSURLSessionConfiguration.defaultSessionConfiguration())
        self.requestManager.startRequestsImmediately = false
    }
    
    public func get(url:String,cancellationToken:CancellationToken? = nil,data:String? = nil,completion:(ErrorType?,String?)->()) -> Request{
        return sendRequest(.GET, url: url, cacellationToken: cancellationToken, data: nil,completion: completion)
    }
    
    public func post(url:String,cancellationToken:CancellationToken? = nil,data:String? = nil,completion:(ErrorType?,String?)->()) -> Request{
        return sendRequest(.POST, url: url, cacellationToken: cancellationToken, data: data,completion: completion)
    }
    
    private func sendRequest(method:Alamofire.Method,url:String,cacellationToken:CancellationToken?,data:String?,completion:(ErrorType?,String?)->())-> Request{
        
        var req: Request
        
        if method == .GET{
            req = Alamofire.request(method,url)
        }else{
            req = Alamofire.request(method, url, parameters: [:], encoding: .Custom({
                (convertible,params) in
                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                
                if data != nil && data?.isEmpty == false{
                    mutableRequest.HTTPBody = data!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                }
                
                return (mutableRequest,nil)
            }))
        }
        
        if cacellationToken != nil{
            cacellationToken?.register({
                () -> Void in
                req.cancel()
            })
        }
        
        req.responseString(){
            response in
            completion(response.result.error,response.result.value)
        }
        
        req.resume()
        
        return req
    }
}

