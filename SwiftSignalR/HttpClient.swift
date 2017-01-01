//
//  HttpClient.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/19.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
public class HttpClient: IHttpClient{
    
    public func get(url:String,cancellationToken:CancellationToken? = nil,data:String? = nil) -> Promise<String>{
        return sendRequest(.GET, url: url, cacellationToken: cancellationToken, data: nil)
    }
    
    public func post(url:String,cancellationToken:CancellationToken? = nil,data:String? = nil) -> Promise<String>{
        return sendRequest(.POST, url: url, cacellationToken: cancellationToken, data: data)
    }
    
    private func sendRequest(method:Alamofire.Method,url:String,cacellationToken:CancellationToken?,data:String?) ->Promise<String>{
        
        //reference:http://stackoverflow.com/questions/29168068/unexpectedly-found-nil-while-unwrapping-an-optional-value-using-alamofire
        let allowedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return Promise{
            fulfill, reject in
            var req: Request
            
            if method == .GET{
                req = Alamofire.request(method, allowedUrl)
                
            }else{
                req = Alamofire.request(method, allowedUrl, parameters: [:], encoding: .Custom({
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
                if response.result.value != nil{
                    fulfill(response.result.value!)
                }else{
                    reject(response.result.error!)
                }
            }
        }
    }
}

