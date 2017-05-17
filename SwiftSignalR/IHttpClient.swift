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
    func get(_ url:String,cancellationToken:CancellationToken?,completion:@escaping(Error?,String?)->())->DataRequest
    
    func post(_ url:String,cancellationToken:CancellationToken?,data:Parameters?,completion:@escaping(Error?,String?)->())->DataRequest
}
