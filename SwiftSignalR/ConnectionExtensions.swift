//
//  ConnectionExtensions.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
extension IConnection{
    public func ensureReconnecting()-> Bool{
        
        if self.changeState(.Connected, newState: .Reconnecting){
            self.onReconnecting()
        }
        
        return self.state == .Reconnecting
    }
}