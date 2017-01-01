//
//  KeepAliveData.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class KeepAliveData{
    
    private let _keepAliveWarnAt: Double = 2.0 / 3.0
    
    private var _timeout: NSTimeInterval = 0
    
    private var _timeoutWarning: NSTimeInterval = 0
    
    private var _checkInterval: NSTimeInterval = 0
    
    public var timeout: NSTimeInterval{
        return _timeout
    }
    
    public var timeoutWarning: NSTimeInterval{
        return _timeoutWarning
    }
    
    public var checkInterval: NSTimeInterval{
        return _checkInterval
    }
    
    init(timeout: NSTimeInterval){
        _timeout = timeout
        _timeoutWarning = timeout * _keepAliveWarnAt
        _checkInterval = timeout - _timeoutWarning/3
        
    }
    
    init(timeout:NSTimeInterval, timeoutWarning:NSTimeInterval,checkInterval:NSTimeInterval){
        _timeout = timeout
        _timeoutWarning = timeoutWarning
        _checkInterval = checkInterval
    }
    
}