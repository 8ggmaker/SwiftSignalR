//
//  SSRLog.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class SSRLog{
    public static func log(error:ErrorType?,message:String?){
        var logStr = ""
        if error != nil{
            logStr = "error:\(error!)"
        }
        if message != nil && message?.isEmpty == false{
            logStr += "message:\(message!)"
        }
        
        if logStr.isEmpty == false{
            print(logStr)
        }
    }
}