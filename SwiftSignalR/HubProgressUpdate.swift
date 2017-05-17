//
//  HubProgressUpdate.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class HubProgressUpdate{
    fileprivate static let idkey = "I"
    
    fileprivate static let dataKey = "D"
    
    open var id: String? = ""
    
    open var data: Any? = ""
    
    public init(parameters: [String:AnyObject]){
        self.id = parameters[HubProgressUpdate.idkey] as? String
        self.data = parameters[HubProgressUpdate.dataKey]
    }
}
