//
//  Exception.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
enum CommonException:Error{
    case invalidArgumentException(exception: String)
    case argumentNullException(exception:String)
    case invalidOperationException(exception: String)
    case timeoutException(exception:String)
}


enum SwiftSignalRException:Error {
    case serverOperationException(exception:String,data:Any?)
}
