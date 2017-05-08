//
//  HeartBeatMonitor.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/27.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class HeartBeatMonitor{
    private var timer: NSTimer! = nil
    
    private var connectionStateLock: SSRLock! = nil
    
    private var connection: IConnection! = nil
    
    private var beatInterval: NSTimeInterval = 0
    
    private var monitorKeepAlive: Bool = false
    
    private var hasBeenWarned: Bool = false
    
    private var timeout: Bool = false
    
    public init(connection: IConnection, connectionStateLock:SSRLock, beatInterval: NSTimeInterval){
        self.beatInterval = beatInterval
        self.connection = connection
        self.connectionStateLock = connectionStateLock
    }
    
    public func start(){
        monitorKeepAlive = (connection.keepAliveData != nil && connection.transport.supportKeepAlive == true)
        clearFlags()
        if timer != nil{
            timer.invalidate()
        }
        timer = NSTimer(timeInterval: beatInterval, target: self, selector: #selector(heatBeat), userInfo: nil, repeats: true)
    }
    
    private func clearFlags(){
        hasBeenWarned = false
        timeout = false
    }
    
    @objc private func heatBeat(){
        let timeElapsed = NSDate().timeIntervalSinceDate(connection.lastMessageAt)
        beat(timeElapsed)
    }
    
    private func beat(timeElapsed: NSTimeInterval){
        if monitorKeepAlive {
            checkKeepAlive(timeElapsed)
        }
        connection.markActive()
    }
    
    private func checkKeepAlive(timeElapsed:NSTimeInterval){
        connectionStateLock.performLocked({
            () -> Void in
            
            if self.connection.state == .Connected{
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