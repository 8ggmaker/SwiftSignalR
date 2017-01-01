//
//  StringExtensions.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
extension String {
    
    func encodeURIComponent() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-_.!~*'()")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}