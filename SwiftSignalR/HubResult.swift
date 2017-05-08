//
//  HubResult.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HubResult{
    private static let idkey = "I"
    
    private static let progressUpdateKey = "P"
    
    private static let resultKey = "R"
    
    private static let isHubExceptionKey = "H"
    
    private static let errorKey = "E"
    
    private static let errorDataKey = "D"
    
    private static let stateKey = "S"
    
    public var id: String? = ""
    
    public var progressUpdate: HubProgressUpdate? = nil
    
    public var result: Any? = nil
    
    public var isHubException: Bool? = nil
    
    public var error: String? = nil
    
    public var errorData: Any? = nil
    
    public var state: [String:AnyObject]? = nil
    
    
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