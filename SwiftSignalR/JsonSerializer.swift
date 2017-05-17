//
//  JsonSerializer.swift
//  SwiftSignalR
//
//  Created by zsy on 2017/5/4.
//  Copyright © 2017年 zsy. All rights reserved.
//

import Foundation
class JsonSerializer{
    class func generateValidJsonObject(_ object:Any?)throws ->Any?{
        if let dic = object as? NSDictionary{
            let jsonDic = NSMutableDictionary()
            for key in dic.allKeys{
                if let validKeyStr = key as? String{
                    jsonDic.setValue(try generateValidJsonObject(dic[key]), forKey: validKeyStr)
                }else{
                    throw CommonException.invalidArgumentException(exception: "object cannot transfer to valid json object")
                }
            }
            return jsonDic
        }else if let arr = object as? NSArray{
            let jsonArr = NSMutableArray()
            for val in arr{
                let obj = try generateValidJsonObject(val as AnyObject?)
                if obj == nil{
                    jsonArr.add(NSNull())
                }else{
                    jsonArr.add(obj!)
                }
            }
            return jsonArr
        }else if isFoundationType(object){
            return object
        }else if let jsonable = object as? Jsonable{
            let json = jsonable.toJsonObject()
            return try generateValidJsonObject(json)
        }
        
        throw CommonException.invalidArgumentException(exception: "object cannot transfer to valid json object")
    }
    
    static func isFoundationType(_ object:Any?)->Bool{
        return object == nil || object is Int8 || object is Int8?
                || object is Int16 || object is Int16? || object is Int32
                || object is Int32? || object is Int64 || object is Int64?
                || object is Float || object is Float? || object is Double
                || object is Double? || object is String || object is String? || object is NSDate
                || object is Date?
    }
}
