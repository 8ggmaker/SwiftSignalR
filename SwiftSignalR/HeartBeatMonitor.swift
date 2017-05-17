//
//  HeartBeatMonitor.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/27.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

open class HeartBeatMonitor{
    fileprivate var timer: Timer! = nil
    
    fileprivate var connectionStateLock: SSRLock! = nil
    
    fileprivate var connection: IConnection! = nil
    
    fileprivate var beatInterval: TimeInterval = 0
    
    fileprivate var monitorKeepAlive: Bool = false
    
    fileprivate var hasBeenWarned: Bool = false
    
    fileprivate var timeout: Bool = false
    
    public init(connection: IConnection, connectionStateLock:SSRLock, beatInterval: TimeInterval){
        self.beatInterval = beatInterval
        self.connection = connection
        self.connectionStateLock = connectionStateLock
    }
    
    open func start(){
        monitorKeepAlive = (connection.keepAliveData != nil && connection.transport.supportKeepAlive == true)
        clearFlags()
        if timer != nil{
            timer.invalidate()
        }
        timer = Timer(timeInterval: beatInterval, target: self, selector: #selector(heatBeat), userInfo: nil, repeats: true)
    }
    
    fileprivate func clearFlags(){
        hasBeenWarned = false
        timeout = false
    }
    
    @objc fileprivate func heatBeat(){
        let timeElapsed = Date().timeIntervalSince(connection.lastMessageAt as Date)
        beat(timeElapsed)
    }
    
    fileprivate func beat(_ timeElapsed: TimeInterval){
        if monitorKeepAlive {
            checkKeepAlive(timeElapsed)
        }
        connection.markActive()
    }
    
    fileprivate func checkKeepAlive(_ timeElapsed:TimeInterval){
        connectionStateLock.performLocked({
            () -> Void in
            
            if self.connection.state == .connected{
                if timeElapsed >= self.connection.keepAliveData?.timeout{
                    if !self.timeout{
                        self.timeout = true
                        self.connection.transport.lostConnection(self.connection)
                    }
                }else if timeElapsed >= self.connection.keepAliveData?.timeoutWarning{
                    if !self.hasBeenWarned{
                        self.hasBeenWarned = true
                        self.connection.onConnectionSlow()
                    }
                }else{
                    self.clearFlags()
                }
            }
        })
    }
    
    func Reconnected(){
        clearFlags()
    }
    
}
