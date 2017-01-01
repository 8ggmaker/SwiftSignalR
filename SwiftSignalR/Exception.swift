//
//  Exception.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
enum CommonException:ErrorType{
    case InvalidArgumentException(exception: String)
    case ArgumentNullException(exception:String)
    case InvalidOperationException(exception: String)
    case TimeoutException(exception:String)
}


enum SwiftSignalRException:ErrorType {
}