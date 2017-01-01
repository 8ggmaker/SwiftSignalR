//
//  UrlBuilder.swift
//  SwiftSignalR
//
//  Created by zsy on 16/11/13.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class UrlBuilder{
    public static func buildNegotiate(connection: IConnection?, connectionData: String?) throws -> String{
        if connection == nil || connectionData == nil{
            throw CommonException.ArgumentNullException(exception:"connection or connection data is nil")
        }
        
        let urlString = createBaseUrl("negotiate", connection: connection!, transport: nil, connectionData: connectionData!)
        
        return trim(urlString)
    }
    
    public static func buildStart(connection:IConnection?,transport:String?,connectionData:String) throws ->String{
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("start", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    public static func buildConnect(connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("connect", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    public static func buildReconnect(connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("reconnect", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    public static func buildPoll(connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        let baseUrl = createBaseUrl("poll", connection: connection!, transport: transport!, connectionData: connectionData)
        let urlString = appendReceiveParameters(baseUrl, connection: connection!)
        return trim(urlString)
    }
    
    public static func buildSend(connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        return trim(createBaseUrl("send", connection: connection!, transport: transport!, connectionData: connectionData))
    }
    
    public static func buildAbort(connection:IConnection?,transport:String?,connectionData:String) throws -> String{
        
        if connection == nil{
            throw CommonException.ArgumentNullException(exception: "connection")
        }
        
        if transport == nil || transport?.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "transport")
        }
        
        return trim(createBaseUrl("abort", connection: connection!, transport: transport!, connectionData: connectionData))
    }
    
    private static func createBaseUrl(command: String, connection: IConnection, transport: String?, connectionData: String) -> String{
        
        var urlStr = ""
        urlStr.appendContentsOf(connection.url)
        urlStr.appendContentsOf(command)
        urlStr.appendContentsOf("?")
        
        return appendCommandParameters(urlStr,connection:connection,transport:transport,connectionData:connectionData)
        
    }
    
    private static func appendCommandParameters(urlString:String,connection:IConnection,transport:String?,connectionData:String)-> String{
        var tempStr = urlString
        tempStr = appendClientProtocol(tempStr,connection:connection)
        tempStr = appendTransport(tempStr,transport:transport)
        tempStr = appendConnectionData(tempStr,connectionData:connectionData)
        tempStr = appendConnectionToken(tempStr,connection:connection)
        tempStr = appendCustomQueryString(tempStr,connection: connection)
        
        return tempStr
    }
    
    private static func appendReceiveParameters(urlString:String,connection:IConnection) -> String{
        var tempStr = urlString
        
        tempStr = appendMessageId(tempStr, connection: connection)
        tempStr = appendGroupsToken(tempStr, connection: connection)
        
        return tempStr
    }
    
    private static func trim(urlString:String) -> String{
        
        var tempStr = urlString
        
        assert(tempStr.characters.last == "&", "expected & at the end of url")
        
        tempStr.removeAtIndex(tempStr.endIndex.advancedBy(-1))
        
        return tempStr
    }
    
    
    private static func appendClientProtocol(urlString:String,connection:IConnection)-> String{
        var tempStr = urlString
        tempStr.appendContentsOf("clientProtocol=");
        tempStr.appendContentsOf("\(connection.clientProtocol)")
        tempStr.appendContentsOf("&")
        
        return tempStr
    }
    
    private static func appendTransport(urlString:String,transport:String?)-> String{
        var tempStr = urlString
        
        if transport != nil && transport?.isEmpty == false{
            tempStr.appendContentsOf("transport=")
            tempStr.appendContentsOf(transport!)
            tempStr.appendContentsOf("&")
        }

        return tempStr
    }
    
    private static func appendConnectionData(urlString:String,connectionData:String?) ->String{
        
        var tempStr = urlString
        
        if connectionData != nil && connectionData?.isEmpty == false{
            tempStr.appendContentsOf("connectionData=")
            tempStr.appendContentsOf(connectionData!)
            tempStr.appendContentsOf("&")
        }
        return tempStr
    }
    
    private static func appendConnectionToken(urlString:String,connection:IConnection) ->String{
        
        var tempStr = urlString
        if connection.connectionToken != nil && connection.connectionToken?.isEmpty == false{
            tempStr.appendContentsOf("connectionToken=")
            tempStr.appendContentsOf(connection.connectionToken!.encodeURIComponent()!)
            tempStr.appendContentsOf("&")
        }
        return tempStr
    }
    private static func appendCustomQueryString(urlString:String,connection:IConnection) ->String{
        
        var tempStr = urlString
        
        if connection.queryString == nil || connection.queryString?.isEmpty == true{
            return tempStr
        }
        let firstIdx = connection.queryString!.startIndex
        
        let firstchar = connection.queryString![firstIdx]
        if firstchar == "?" || firstchar == "&"{
            tempStr.appendContentsOf(connection.queryString!.substringFromIndex(firstIdx.advancedBy(1)))
        }
        else{
            tempStr.appendContentsOf(connection.queryString!)
        }
        
        tempStr.appendContentsOf("&")
        
        return tempStr
    }
    
    private static func appendMessageId(urlString:String,connection: IConnection) -> String{
        
        var tempStr = urlString
        
        let messageId = connection.messageId
        
        if messageId != nil && messageId?.isEmpty == false{
            tempStr.appendContentsOf("messageId=")
            tempStr.appendContentsOf(connection.messageId!)
            tempStr.appendContentsOf("&")
        }
        
        return tempStr
    }
    
    private static func appendGroupsToken(urlString:String, connection:IConnection) -> String{
        
        var tempStr = urlString
        
        let groupsToken = connection.groupsToken
        
        if groupsToken != nil && groupsToken?.isEmpty == false{
            tempStr.appendContentsOf("groupsToken=")
            tempStr.appendContentsOf(groupsToken!.encodeURIComponent()!)
            tempStr.appendContentsOf("&")
        }
        
        return tempStr
    }
    
    public static func convertToWebSocketUri(uriString:String)-> String? {
        
        let urlComponment = NSURLComponents(string: uriString)
        
        if urlComponment == nil{
            return nil
        }
        
        if urlComponment?.scheme != "http" && urlComponment?.scheme != "https"{
            return nil
        }
        
        urlComponment?.scheme = urlComponment?.scheme == "https" ? "wss" : "ws"
        
        return urlComponment?.URL?.absoluteString
    }
    
    
}