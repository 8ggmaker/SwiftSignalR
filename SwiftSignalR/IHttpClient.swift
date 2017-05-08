//
//  IHttpClient.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/19.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import Alamofire
public protocol IHttpClient {
    func get(url:String,cancellationToken:CancellationToken?,data:String?,completion:(ErrorType?,String?)->())->Request
    
    func post(url:String,cancellationToken:CancellationToken?,data:String?,completion:(ErrorType?,String?)->())->Request
}