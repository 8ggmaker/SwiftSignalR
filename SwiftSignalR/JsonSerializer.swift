//
//  JsonSerializer.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/5/4.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
class JsonSerializer{
    class func generateValidJsonObject(object:AnyObject?)throws ->AnyObject?{
        if let dic = object as? NSDictionary{
            let jsonDic = NSMutableDictionary()
            for key in dic.allKeys{
                if let validKeyStr = key as? NSString{
                    jsonDic.setValue(try generateValidJsonObject(dic[validKeyStr]), forKey: validKeyStr as String)
                }else{
                    throw CommonException.InvalidArgumentException(exception: "object cannot transfer to valid json object")
                }
            }
            return jsonDic
        }else if let arr = object as? NSArray{
            let jsonArr = NSMutableArray()
            for val in arr{
                let obj = try generateValidJsonObject(val)
                if obj == nil{
                    jsonArr.addObject(NSNull())
                }else{
                    jsonArr.addObject(obj!)
                }
            }
            return jsonArr
        }else if isFoundationType(object){
            return object
        }else if let jsonable = object as? Jsonable{
            let json = jsonable.toJsonObject()
            return try generateValidJsonObject(json)
        }
        
        throw CommonException.InvalidArgumentException(exception: "object cannot transfer to valid json object")
    }
    
    static func isFoundationType(object:Any?)->Bool{
        return object == nil || object is Int8 || object is Int8?
                || object is Int16 || object is Int16? || object is Int32
                || object is Int32? || object is Int64 || object is Int64?
                || object is Float || object is Float? || object is Double
                || object is Double? || object is String || object is String? || object is NSDate
                || object is NSDate?
    }
}