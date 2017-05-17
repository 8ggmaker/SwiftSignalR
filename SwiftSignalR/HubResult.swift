//
//  HubResult.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class HubResult{
    fileprivate static let idkey = "I"
    
    fileprivate static let progressUpdateKey = "P"
    
    fileprivate static let resultKey = "R"
    
    fileprivate static let isHubExceptionKey = "H"
    
    fileprivate static let errorKey = "E"
    
    fileprivate static let errorDataKey = "D"
    
    fileprivate static let stateKey = "S"
    
    open var id: String? = ""
    
    open var progressUpdate: HubProgressUpdate? = nil
    
    open var result: Any? = nil
    
    open var isHubException: Bool? = nil
    
    open var error: String? = nil
    
    open var errorData: Any? = nil
    
    open var state: [String:AnyObject]? = nil
    
    
    public init(){
        
    }
    
    public init(parameters: [String:AnyObject]){

        self.id = parameters[HubResult.idkey] as? String
        
        if let progressUpdateDic = parameters[HubResult.progressUpdateKey] as? [String:AnyObject]{
            self.progressUpdate = HubProgressUpdate(parameters: progressUpdateDic)
        }
        
        self.result = parameters[HubResult.resultKey]
        
        self.isHubException = parameters[HubResult.isHubExceptionKey] as? Bool
        
        self.error = parameters[HubResult.errorKey] as? String

        self.errorData = parameters[HubResult.errorDataKey]
        
        self.state = parameters[HubResult.stateKey] as? [String:AnyObject]

    }
}
