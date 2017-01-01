//
//  SSRLock.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/26.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
protocol Lock {
    func lock()
    func unlock()
}

public class SSRLock: Lock{
    
    
    private var semaphore: dispatch_semaphore_t! = nil
    
    public init(){
        semaphore = dispatch_semaphore_create(1)
    }
    
    public func lock() {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    public func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    @inline(__always)
    public func performLocked(action:()->Void){
        lock(); defer{
            unlock()
        }
        action()
    }
    
    @inline(__always)
    public func calculateLocked<T>(action:() -> T)->T{
        lock(); defer{
            unlock()
        }
        return action()
    }
    
    @inline(__always)
    public func calculateLockedOrFail<T>(action:()throws -> T)throws ->T{
        lock(); defer{
            unlock()
        }
        return try action()
    }
}