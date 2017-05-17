//
//  UrlBuilder.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class UrlBuilder{
    open static func buildNegotiate(_ connection: IConnection?, connectionData: String?) throws -> String{
        if connection == nil || connectionData == nil{
            throw CommonException.argumentNullException(exception:"connection or connection data is nil")
        }
        
        let urlString = createBaseUrl("negotiate", connection: connection!, transport: nil, connectionData: connectionData!)
        
        return trim(urlString)
    }
    
    open static func buildStart(_ connection:IConnection?,transport:String?,connectionData:String) throws ->String{
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("start", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    open static func buildConnect(_ connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("connect", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    open static func buildReconnect(_ connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("reconnect", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    open static func buildPoll(_ connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("poll", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    open static func buildSend(_ connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        return trim(createBaseUrl("send", connection: connection!, transport: transport!, connectionData: connectionData))
    }
    
    open static func buildAbort(_ connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        
        if connection == nil{
            throw CommonException.argumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.argumentNullException(exception: "transport")
        }
        
        return trim(createBaseUrl("abort", connection: connection!, transport: transport!, connectionData: connectionData))
    }
    
    fileprivate static func createBaseUrl(_ command: String, connection: IConnection, transport: String?, connectionData: String) -> String{
        
        var urlStr = ""
        urlStr.append(connection.url)
        urlStr.append(command)
        urlStr.append("?")
        
        return appendCommandParameters(urlStr,connection:connection,transport:transport,connectionData:connectionData)
        
    }
    
    fileprivate static func appendCommandParameters(_ urlString:String,connection:IConnection,transport:String?,connectionData:String)-> String{
        var tempStr = urlString
        tempStr = appendClientProtocol(tempStr,connection:connection)
        tempStr = appendTransport(tempStr,transport:transport)
        tempStr = appendConnectionData(tempStr,connectionData:connectionData)
        tempStr = appendConnectionToken(tempStr,connection:connection)
        tempStr = appendCustomQueryString(tempStr,connection: connection)
        
        return tempStr
    }
    
    fileprivate static func appendReceiveParameters(_ urlString:String,connection:IConnection) -> String{
        var tempStr = urlString
        
        tempStr = appendMessageId(tempStr, connection: connection)
        tempStr = appendGroupsToken(tempStr, connection: connection)
        
        return tempStr
    }
    
    fileprivate static func trim(_ urlString:String) -> String{
        
        var tempStr = urlString
        
        assert(tempStr.characters.last == "&", "expected & at the end of url")
        
        tempStr.remove(at: tempStr.characters.index(tempStr.endIndex, offsetBy: -1))
        
        return tempStr
    }
    
    
    fileprivate static func appendClientProtocol(_ urlString:String,connection:IConnection)-> String{
        var tempStr = urlString
        tempStr.append("clientProtocol=");
        tempStr.append("\(connection.clientProtocol)")
        tempStr.append("&")
        
        return tempStr
    }
    
    fileprivate static func appendTransport(_ urlString:String,transport:String?)-> String{
        var tempStr = urlString
        
        if transport != nil && transport?.isEmpty == false{
            tempStr.append("transport=")
            tempStr.append(transport!)
            tempStr.append("&")
        }

        return tempStr
    }
    
    fileprivate static func appendConnectionData(_ urlString:String,connectionData:String?) ->String{
        
        var tempStr = urlString
        
        if connectionData != nil && connectionData?.isEmpty == false{
            tempStr.append("connectionData=")
            tempStr.append(connectionData!.encodeURIComponent()!)
            tempStr.append("&")
        }
        return tempStr
    }
    
    fileprivate static func appendConnectionToken(_ urlString:String,connection:IConnection) ->String{
        
        var tempStr = urlString
        if connection.connectionToken != nil && connection.connectionToken?.isEmpty == false{
            tempStr.append("connectionToken=")
            tempStr.append(connection.connectionToken!.encodeURIComponent()!)
            tempStr.append("&")
        }
        return tempStr
    }
    fileprivate static func appendCustomQueryString(_ urlString:String,connection:IConnection) ->String{
        
        var tempStr = urlString
        
        if connection.queryString == nil || connection.queryString?.isEmpty == true{
            return tempStr
        }
        let firstIdx = connection.queryString!.startIndex
        
        let firstchar = connection.queryString![firstIdx]
        if firstchar == "?" || firstchar == "&"{
            tempStr.append(connection.queryString!.substring(from: connection.queryString!.index(after: firstIdx)))
        }
        else{
            tempStr.append(connection.queryString!)
        }
        
        tempStr.append("&")
        
        return tempStr
    }
    
    fileprivate static func appendMessageId(_ urlString:String,connection: IConnection) -> String{
        
        var tempStr = urlString
        
        let messageId = connection.messageId
        
        if messageId != nil && messageId?.isEmpty == false{
            tempStr.append("messageId=")
            tempStr.append(connection.messageId!.encodeURIComponent()!)
            tempStr.append("&")
        }
        
        return tempStr
    }
    
    fileprivate static func appendGroupsToken(_ urlString:String, connection:IConnection) -> String{
        
        var tempStr = urlString
        
        let groupsToken = connection.groupsToken
        
        if groupsToken != nil && groupsToken?.isEmpty == false{
            tempStr.append("groupsToken=")
            tempStr.append(groupsToken!.encodeURIComponent()!)
            tempStr.append("&")
        }
        
        return tempStr
    }
    
    open static func convertToWebSocketUri(_ uriString:String)-> String? {
        
        var urlComponment = URLComponents(string: uriString)
        
        if urlComponment == nil{
            return nil
        }
        
        if urlComponment?.scheme != "http" && urlComponment?.scheme != "https"{
            return nil
        }
        
        urlComponment?.scheme = urlComponment?.scheme == "https" ? "wss" : "ws"
        
        return urlComponment?.url?.absoluteString
    }
    
    
}
