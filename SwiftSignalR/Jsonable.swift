//
//  Jsonable.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/5/3.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
public protocol Jsonable: class{
    
    func toJsonObject()->NSDictionary
}