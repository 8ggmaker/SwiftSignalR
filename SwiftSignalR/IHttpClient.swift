//
//  IHttpClient.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/19.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import PromiseKit
public protocol IHttpClient {
    func get(url:String,cancellationToken:CancellationToken?,data:String?) -> Promise<String>
    
    func post(url:String,cancellationToken:CancellationToken?,data:String?) -> Promise<String>
}