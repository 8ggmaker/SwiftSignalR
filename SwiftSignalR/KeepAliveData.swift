//
//  KeepAliveData.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class KeepAliveData{
    
    fileprivate let _keepAliveWarnAt: Double = 2.0 / 3.0
    
    fileprivate var _timeout: TimeInterval = 0
    
    fileprivate var _timeoutWarning: TimeInterval = 0
    
    fileprivate var _checkInterval: TimeInterval = 0
    
    open var timeout: TimeInterval{
        return _timeout
    }
    
    open var timeoutWarning: TimeInterval{
        return _timeoutWarning
    }
    
    open var checkInterval: TimeInterval{
        return _checkInterval
    }
    
    init(timeout: TimeInterval){
        _timeout = timeout
        _timeoutWarning = timeout * _keepAliveWarnAt
        _checkInterval = timeout - _timeoutWarning/3
        
    }
    
    init(timeout:TimeInterval, timeoutWarning:TimeInterval,checkInterval:TimeInterval){
        _timeout = timeout
        _timeoutWarning = timeoutWarning
        _checkInterval = checkInterval
    }
    
}
