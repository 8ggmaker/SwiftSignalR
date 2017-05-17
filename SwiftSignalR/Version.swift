//
//  Version.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/12.
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class Version: NSObject{
    open var build: Int = 0
    
    open var major: Int = 0
    
    open var majorRevision: Int = 0
    
    open var minor: Int = 0
    
    open var minorRevision: Int = 0
    
    open var revision: Int = 0
    
    override init(){
        super.init()
        build = 0
        major = 0
        majorRevision = 0
        minor = 0
        minorRevision = 0
        revision = 0
        
    }
    
    init(major:Int,minor:Int) throws {
        super.init()
        self.major = major
        self.minor = minor
        
        if major < 0 || minor < 0{
            throw CommonException.invalidArgumentException(exception:"Component cannot be less than 0, major: \(major), minor: \(minor)")
        }
    }
    
    convenience init(major:Int, minor:Int, build: Int) throws {
        try self.init(major:major,minor: minor)
        self.build = build
        if build < 0{
            throw CommonException.invalidArgumentException(exception: "Component cannot be less than 0, build: \(build)")
        }
    }
    
    convenience init(major:Int, minor: Int, build: Int, revision:Int) throws {
        try self.init(major:major,minor:minor,build: build)
        self.revision = revision
        if revision < 0{
            throw CommonException.invalidArgumentException(exception: "Component cannot be less than 0, revision: \(revision)")
        }
    }
    
    static func tryParse(_ input:String?, version: inout Version) -> Bool{
        
        if input == nil || input?.isEmpty == true{
            return false
        }
        
        let components = input?.components(separatedBy: ".")
        if components == nil || components?.count < 2 || components?.count > 4{
            return false
        }
        
        let temp = Version()
        
        for (idx,val) in components!.enumerated(){
            
            switch idx {
            case 0:
                temp.major = Int(val)!
                break
            case 1:
                temp.minor = Int(val)!
                break
            case 2:
                temp.build = Int(val)!
                break
            case 3:
                temp.revision = Int(val)!
                break
            default:
                break
            }
        }
        version = temp
        
        return true
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        if object == nil {
            return false
        }
        
        guard let versionObject = object as? Version else{
            return false
        }
        
        return self.major == versionObject.major && self.minor == versionObject.minor && self.build == versionObject.build
               && self.revision == versionObject.revision
    }
    
    override open var description: String{
        return "\(major).\(minor).\(build).\(revision)"
    }

}
