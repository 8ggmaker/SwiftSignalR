//
//  WebSocketTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import SocketRocket

public class WebSocketTransport: ClientBaseTransport{
    
    private var websocket: SRWebSocket?
    
    private var socketWorkerQueue:dispatch_queue_t = dispatch_queue_create("socketrocketwork", nil)
    
    private var reconnectTaskQueue: dispatch_queue_t = dispatch_queue_create("reconnecttask", nil)
    
    private var reconnectDelay: NSTimeInterval!
    
    private var reconnectLock: SSRLock!
        
    public init(httpClient: IHttpClient) {
        websocket = nil
        reconnectDelay = NSTimeInterval(2)
        reconnectLock = SSRLock()
        
        super.init(name: "webSockets", httpClient: httpClient)
    }
    
    public override var supportKeepAlive: Bool{
        get{
            return true
        }
    }
    
    public override func start(connection: IConnection, connectionData: String, disconnectToken: CancellationToken,completion:(ErrorType?)->()) {
        self.completion = completion
        initialize(connection, connectionData: connectionData, disconnectToken: disconnectToken)
        do{
            let connectUrl = try UrlBuilder.buildConnect(connection, transport: name, connectionData: connectionData)
            
            performConnect(connection,url:connectUrl)
        }catch let err{
            connection.onError(err)
            self.completion?(err)
        }

    }
    
    public override func send(connection: IConnection, data:String, connectionData:String,completionHandler:((response:Any?,error:ErrorType?)->())?){
        if self.websocket == nil || self.websocket?.readyState != SRReadyState.OPEN{
            let err = CommonException.InvalidOperationException(exception: "websocket not initialized")
            if completionHandler != nil{
                completionHandler!(response: nil, error: err)
            }
        }
        
        websocket?.send(data)
        if completionHandler != nil{
            completionHandler!(response: nil,error: nil)
        }
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
    
    private func performConnect(connection:IConnection,url:String){
        
        let wsUrl = UrlBuilder.convertToWebSocketUri(url)
        if wsUrl == nil{
            self.completion?(CommonException.ArgumentNullException(exception: "wsurl"))
            connection.onError(CommonException.ArgumentNullException(exception: "wsurl"))
            return
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
            }
        })
        
        websocket?.open()
        
    }
    
    private func stopWebSocket(){
        websocket?.delegate = nil
        websocket?.close()
        websocket = nil
    }
    
    private func doReconnect(){
        
        
        let delay = dispatch_time(DISPATCH_TIME_NOW,
                                  Int64(self.reconnectDelay * Double(NSEC_PER_SEC)))
        dispatch_after(delay, self.reconnectTaskQueue){
            do{
                let reconnectUrl = try UrlBuilder.buildReconnect(self.connectionInfo.connection, transport: self.name, connectionData: self.connectionInfo.connectionData)
                if try TransportHelper.verifyLastActive(self.connectionInfo.connection) && self.connectionInfo.connection.ensureReconnecting(){
                    self.performConnect(self.connectionInfo.connection, url: reconnectUrl)
                }
                
                
                
            }catch let err{
                self.connectionInfo.connection.onError(err)

            }
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
            self.doCompletionCallback(error)
            return
        }
        
        self.connectionInfo.connection.onError(error)

        if abortHandler.TryCompleteAbort(){
            return
        }
        
        doReconnect()
        
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