//
//  ConnectionState.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public enum ConnectionState:Int{
    case connecting = 0
    case connected
    case reconnecting
    case disconnected
}
