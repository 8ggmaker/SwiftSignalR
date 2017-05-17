//
//  HttpClient.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/19.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
open class HttpClient: IHttpClient{
    
    fileprivate var requestManager: SessionManager
    
    public init(){
        self.requestManager = Alamofire.SessionManager(configuration:URLSessionConfiguration.default)
        self.requestManager.startRequestsImmediately = false
    }
    
    open func get(_ url:String,cancellationToken:CancellationToken? = nil,completion:@escaping (Error?,String?)->()) -> DataRequest{
        return sendRequest(.get, url: url, cacellationToken: cancellationToken, data: nil,completion: completion)
    }
    
    open func post(_ url:String,cancellationToken:CancellationToken? = nil,data:Parameters? = nil,completion:@escaping (Error?,String?)->()) -> DataRequest{
        return sendRequest(.post, url: url, cacellationToken: cancellationToken, data: data,completion: completion)
    }
    
    fileprivate func sendRequest(_ method:HTTPMethod,url:String,cacellationToken:CancellationToken?,data:Parameters?,completion:@escaping (Error?,String?)->())-> DataRequest{
        
        var req: DataRequest
        
        if method == .get{
            req = requestManager.request(url,method:method)
        }else{
            
            req = requestManager.request(url, method: method, parameters: data, encoding: URLEncoding.httpBody)
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

