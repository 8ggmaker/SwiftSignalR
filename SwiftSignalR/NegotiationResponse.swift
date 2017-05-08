//
//  NegotiationResponse.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import EVReflection
public class NegotiationResponse: EVObject{
    public var connectionId: String = ""
    public var connectionToken: String = ""
    public var url: String = ""
    public var protocolVersion: String = ""
    public var disconnectTimeout: Double = 0.0
    public var tryWebSockets: Bool = true
    public var keepAliveTimeout: Double? = nil
    public var transportConnectTimeout: Double = 0.0
    
}

