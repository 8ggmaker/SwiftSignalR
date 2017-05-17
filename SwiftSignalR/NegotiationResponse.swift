//
//  NegotiationResponse.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class NegotiationResponse{
    
    fileprivate static let connectionIdKey:String = "ConnectionId"
    fileprivate static let connectionTokenKey:String = "ConnectionToken"
    fileprivate static let urlKey: String = "Url"
    fileprivate static let protocolVersionKey: String = "ProtocolVersion"
    fileprivate static let disconnectTimeoutKey:String = "DisconnectTimeout"
    fileprivate static let tryWebSocketsKey: String = "TryWebSockets"
    fileprivate static let keepAliveTimeoutKey:String = "KeepAliveTimeout"
    fileprivate static let transportConnectTimeoutKey:String = "TransportConnectTimeout"
    
    public var connectionId: String = ""
    public var connectionToken: String = ""
    public var url: String = ""
    public var protocolVersion: String = ""
    public var disconnectTimeout: Double = 0.0
    public var tryWebSockets: Bool = true
    public var keepAliveTimeout: Double? = nil
    public var transportConnectTimeout: Double = 0.0
    
    public init(parameters:[String:Any]){
        if let connectionId = parameters[NegotiationResponse.connectionIdKey] as? String{
            self.connectionId = connectionId
        }
        
        if let connectionToken = parameters[NegotiationResponse.connectionTokenKey] as? String{
            self.connectionToken = connectionToken
        }
        
        if let url = parameters[NegotiationResponse.urlKey] as? String{
            self.url = url
        }
        
        if let protocolVersion = parameters[NegotiationResponse.protocolVersionKey] as? String{
            self.protocolVersion = protocolVersion
        }
        
        if let disconnectTimeout = parameters[NegotiationResponse.disconnectTimeoutKey] as? Double{
            self.disconnectTimeout = disconnectTimeout
        }
        
        if let tryWebSockets = parameters[NegotiationResponse.tryWebSocketsKey] as? Bool{
            self.tryWebSockets = tryWebSockets
        }
        
        if let keepAliveTimeout = parameters[NegotiationResponse.keepAliveTimeoutKey] as? Double{
            self.keepAliveTimeout = keepAliveTimeout
        }
        
        if let transportConnectTimeout = parameters[NegotiationResponse.transportConnectTimeoutKey] as? Double{
            self.transportConnectTimeout = transportConnectTimeout
        }
        
    }
    
}

