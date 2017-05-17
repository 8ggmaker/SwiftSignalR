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

open class SSRLock: Lock{
    
    
    fileprivate var semaphore: DispatchSemaphore! = nil
    
    public init(){
        semaphore = DispatchSemaphore(value: 1)
    }
    
    open func lock() {
        semaphore.wait()
    }
    
    open func unlock() {
        semaphore.signal()
    }
    
    @inline(__always)
    open func performLocked(_ action:()->Void){
        lock(); defer{
            unlock()
        }
        action()
    }
    
    @inline(__always)
    open func calculateLocked<T>(_ action:() -> T)->T{
        lock(); defer{
            unlock()
        }
        return action()
    }
    
    @inline(__always)
    open func calculateLockedOrFail<T>(_ action:()throws -> T)throws ->T{
        lock(); defer{
            unlock()
        }
        return try action()
    }
}
