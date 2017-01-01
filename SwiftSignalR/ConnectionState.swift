//
//  ConnectionState.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public enum ConnectionState:Int{
    case Connecting = 0
    case Connected
    case Reconnecting
    case Disconnected
}