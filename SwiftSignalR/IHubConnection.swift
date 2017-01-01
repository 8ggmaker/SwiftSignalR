//
//  IHubConnection.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/30.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public protocol IHubConnection:class{
    func registerCallback(callback: (HubResult?->()))-> String?
    
    func removeCallback(callbackId:String)
}