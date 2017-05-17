//
//  IHubProxy.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/31.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IHubProxy:class {
    func on(_ method:String,action:@escaping ([AnyObject?]?)->())-> Subscription?
    
    func invoke(_ method:String,params:[AnyObject?]?)
    
    func invoke(_ method:String,params:[AnyObject?]?,completionHandler:((_ response:Any?,_ error:Error?)->())?)
    
    func invoke(_ method:String,onProgress:((Any?)->())?,params:[AnyObject?]?,completionHandler:((_ response:Any?,_ error:Error?)->())?)
         
}
