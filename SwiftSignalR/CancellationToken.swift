//
//  CancellationToken.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation

public struct CancellationToken{
    private unowned let _source: CancellationSource
    
    init(source:CancellationSource){
        self._source = source
    }
    
    public func register(clourse: ()->Void){
        _source.register(clourse)
    }
    
    public var isCancelling: Bool{
        get{
            return _source._isCancelling
        }
    }
}

public class CancellationSource:NSObject{
    
    private var _callbacks: [()->Void]? = []
    
    var _isCancelling: Bool = false
    
    private var _lockQueue: dispatch_queue_t = dispatch_queue_create("CancellationSource.lockQueue",DISPATCH_QUEUE_SERIAL)
    
    public var token: CancellationToken{
        return CancellationToken(source:self)
    }
    
    func register(closure: ()->Void){
        if _isCancelling{
            return
        }
        dispatch_sync(_lockQueue){
            if self._isCancelling{
                closure()
            }else{
                self._callbacks?.append(closure)
            }
        }
    }
    
    public func cancel(){
        if _isCancelling {
            return
        }
        
        dispatch_sync(_lockQueue){
            if !self._isCancelling {
                self._isCancelling = true
                self._callbacks?.forEach{$0()}
                self._callbacks?.removeAll()
            }
        }
    }
    
    public func dispose(){
        self._callbacks = nil
    }
    
}