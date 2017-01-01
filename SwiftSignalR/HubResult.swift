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
    
    public var state: NSMutableDictionary? = nil
    
    
    public init(){
        
    }
    
    public init(parameters: NSMutableDictionary){
        if parameters[HubResult.idkey] != nil && parameters[HubResult.idkey] is String{
            id = parameters[HubResult.idkey] as? String
        }
        
        if parameters[HubResult.progressUpdateKey] != nil && parameters[HubResult.progressUpdateKey
            ] is NSMutableDictionary{
            progressUpdate = HubProgressUpdate(parameters: parameters[HubResult.progressUpdateKey] as!NSMutableDictionary)
        }
        
        if parameters[HubResult.resultKey] != nil{
            result = parameters[HubResult.resultKey]
        }
        
        if parameters[HubResult.isHubExceptionKey] != nil && parameters[HubResult.isHubExceptionKey
            ] is Bool{
            isHubException = parameters[HubResult.isHubExceptionKey] as? Bool
        }
        
        if parameters[HubResult.errorKey] != nil && parameters[HubResult.errorKey] is String{
            error = parameters[HubResult.errorKey] as? String
        }
        
        if parameters[HubResult.errorDataKey] != nil{
            errorData = parameters[HubResult.errorDataKey]
        }
        
        if parameters[HubResult.stateKey] != nil &&  parameters[HubResult.stateKey] is NSMutableDictionary{
            state = parameters[HubResult.stateKey] as? NSMutableDictionary
        }
    }
}