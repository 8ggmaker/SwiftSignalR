//
//  WebSocketTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import PromiseKit
import SocketRocket

public class WebSocketTransport: ClientBaseTransport{
    
    private var websocket: SRWebSocket?
    
    private var socketWorkerQueue:dispatch_queue_t = dispatch_queue_create("socketrocketwork", nil)
        
    
    private var reconnectDelay: NSTimeInterval!
    
    private var shouldBreakReconnecting: Bool = false
    
    public init(httpClient: IHttpClient) {
        websocket = nil
        reconnectDelay = NSTimeInterval(2)
        
        super.init(name: "webSockets", httpClient: httpClient)
    }
    
    public override var supportKeepAlive: Bool{
        get{
            return true
        }
    }
    
    public override func start(connection: IConnection, connectionData: String, disconnectToken: CancellationToken)throws -> Promise<Void> {
        do{
            initialize(connection, connectionData: connectionData, disconnectToken: disconnectToken)
            let connectUrl = try UrlBuilder.buildConnect(connection, transport: name, connectionData: connectionData)
            return performConnect(connection, url: connectUrl)
        }catch let err{
            connection.onError(err)
            throw err
        }
    }
    
    public override func send(connection: IConnection, data:String, connectionData:String,completionHandler:(response:Any?,error:ErrorType?)->Void){
        if self.websocket == nil || self.websocket?.readyState != SRReadyState.OPEN{
            let err = CommonException.InvalidOperationException(exception: "websocket not initialized")
            completionHandler(response: nil, error: err)
        }
        
        websocket?.send(data)
        completionHandler(response: nil,error: nil)
    }
    
    public override  func lostConnection(connection: IConnection) {
        SSRLog.log(nil, message: "websocket lost connection")
        
        self.stopWebSocket()
        
        if connectionInfo.disconnectToken.isCancelling{
            return
        }
        
        if abortHandler.TryCompleteAbort(){
            return
        }
        
        doReconnect()
    }
    
    private func performConnect(connection:IConnection,url:String) -> Promise<Void>{
        startPromiseWrapper = TransportStartPromiseWapper<Void>()
        
        let wsUrl = UrlBuilder.convertToWebSocketUri(url)
        if wsUrl == nil{
            startPromiseWrapper.reject(CommonException.ArgumentNullException(exception: "wsurl"))
        }
        
        let req = connection.prepareRequest(NSMutableURLRequest(URL: NSURL(string: wsUrl!)!))
        req.timeoutInterval = connection.totalTransportConnectTimeout
        
        
        websocket = SRWebSocket(URLRequest: req)
        websocket?.setDelegateDispatchQueue(socketWorkerQueue)
        websocket?.delegate = self
        
        connectionInfo.disconnectToken.register({
            ()->Void in
            if self.websocket != nil{
                self.websocket?.closeWithCode(SRStatusCodeNormal.rawValue, reason: "request cancelled")
                self.websocket = nil
                self.shouldBreakReconnecting = true
            }
        })
        
        websocket?.open()
        
        return startPromiseWrapper.promise
    }
    
    private func stopWebSocket(){
        websocket?.delegate = nil
        websocket?.close()
        websocket = nil
    }
    
    private func doReconnect(){
        
        do{
            
            
            let reconnectUrl = try UrlBuilder.buildReconnect(connectionInfo.connection, transport: name, connectionData: connectionInfo.connectionData)
            
            shouldBreakReconnecting = false
            
            connectionInfo.disconnectToken.register({
                ()->Void in
                self.shouldBreakReconnecting = true
            })
            
            while try TransportHelper.verifyLastActive(connectionInfo.connection) && connectionInfo.connection.ensureReconnecting() && !shouldBreakReconnecting{
                after(reconnectDelay).then{
                    self.performConnect(self.connectionInfo.connection, url: reconnectUrl)
                    }.error{
                        err in
                        self.connectionInfo.connection.onError(err)
                }
            }
            
        }
        catch let err{
            connectionInfo.connection.onError(err)
        }
        
    }
    
    
}

extension WebSocketTransport:SRWebSocketDelegate{
    @objc public func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
        self.processResponse(connectionInfo.connection, message: message as! String)
    }
    
    public func webSocketDidOpen(webSocket: SRWebSocket!){
        if self.connectionInfo.connection.changeState(.Reconnecting, newState: .Connected) == true{
           self.connectionInfo.connection.onReconnected()
        }
    }
    public func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!){
        self.stopWebSocket()

        if self.connected == false{
            self.startPromiseWrapper.reject(error)
        }
        self.connectionInfo.connection.onError(error)
        
        
    }
    public func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool){
        
        if self.connectionInfo.disconnectToken.isCancelling{
            return
        }
        
        if abortHandler.TryCompleteAbort(){
            return
        }
        
        doReconnect()
        
    }
    public func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!){
        
    }
}