//
//  HubProgressUpdate.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HubProgressUpdate{
    private static let idkey = "I"
    
    private static let dataKey = "D"
    
    public var id: String? = ""
    
    public var data: Any? = ""
    
    public init(parameters: [String:AnyObject]){
        self.id = parameters[HubProgressUpdate.idkey] as? String
        self.data = parameters[HubProgressUpdate.dataKey]
    }
}