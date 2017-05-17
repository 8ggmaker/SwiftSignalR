//
//  CancellationToken.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation

public struct CancellationToken{
    fileprivate unowned let _source: CancellationSource
    
    init(source:CancellationSource){
        self._source = source
    }
    
    public func register(_ clourse: @escaping ()->Void){
        _source.register(clourse)
    }
    
    public var isCancelling: Bool{
        get{
            return _source._isCancelling
        }
    }
}

open class CancellationSource:NSObject{
    
    fileprivate var _callbacks: [()->Void]? = []
    
    var _isCancelling: Bool = false
    
    fileprivate var _lockQueue: DispatchQueue = DispatchQueue(label: "CancellationSource.lockQueue",attributes: [])
    
    open var token: CancellationToken{
        return CancellationToken(source:self)
    }
    
    func register(_ closure: @escaping ()->Void){
        if _isCancelling{
            return
        }
        _lockQueue.sync{
            if self._isCancelling{
                closure()
            }else{
                self._callbacks?.append(closure)
            }
        }
    }
    
    open func cancel(){
        if _isCancelling {
            return
        }
        
        _lockQueue.sync{
            if !self._isCancelling {
                self._isCancelling = true
                self._callbacks?.forEach{$0()}
                self._callbacks?.removeAll()
            }
        }
    }
    
    open func dispose(){
        self._callbacks = nil
    }
    
}
