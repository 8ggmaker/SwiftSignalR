//
//  WebSocketTransport.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/20.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
import SocketRocket

open class WebSocketTransport: ClientBaseTransport{
    
    fileprivate var websocket: SRWebSocket?
    
    fileprivate var socketWorkerQueue:DispatchQueue = DispatchQueue(label: "socketrocketwork", attributes: [])
    
    fileprivate var reconnectTaskQueue: DispatchQueue = DispatchQueue(label: "reconnecttask", attributes: [])
    
    fileprivate var reconnectDelay: TimeInterval!
    
    fileprivate var reconnectLock: SSRLock!
        
    public init(httpClient: IHttpClient) {
        websocket = nil
        reconnectDelay = TimeInterval(2)
        reconnectLock = SSRLock()
        
        super.init(name: "webSockets", httpClient: httpClient)
    }
    
    open override var supportKeepAlive: Bool{
        get{
            return true
        }
    }
    
    open override func start(_ connection: IConnection, connectionData: String, disconnectToken: CancellationToken,completion:@escaping (Error?)->()) {
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
    
    open override func send(_ connection: IConnection, data:String, connectionData:String,completionHandler:((_ response:Any?,_ error:Error?)->())?){
        if self.websocket == nil || self.websocket?.readyState != SRReadyState.OPEN{
            let err = CommonException.invalidOperationException(exception: "websocket not initialized")
            if completionHandler != nil{
                completionHandler!(nil, err)
            }
        }
        
        websocket?.send(data)
        if completionHandler != nil{
            completionHandler!(nil,nil)
        }
    }
    
    open override  func lostConnection(_ connection: IConnection) {
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
    
    fileprivate func performConnect(_ connection:IConnection,url:String){
        
        let wsUrl = UrlBuilder.convertToWebSocketUri(url)
        if wsUrl == nil{
            self.completion?(CommonException.argumentNullException(exception: "wsurl"))
            connection.onError(CommonException.argumentNullException(exception: "wsurl"))
            return
        }
        
        var req = connection.prepareRequest(URLRequest(url: URL(string: wsUrl!)!))
        req.timeoutInterval = connection.totalTransportConnectTimeout
        
        
        websocket = SRWebSocket(urlRequest: req as URLRequest!)
        websocket?.setDelegateDispatchQueue(socketWorkerQueue)
        websocket?.delegate = self
        
        connectionInfo.disconnectToken.register({
            ()->Void in
            if self.websocket != nil{
                self.websocket?.close(withCode: SRStatusCodeNormal.rawValue, reason: "request cancelled")
                self.websocket = nil
            }
        })
        
        websocket?.open()
        
    }
    
    fileprivate func stopWebSocket(){
        websocket?.delegate = nil
        websocket?.close()
        websocket = nil
    }
    
    fileprivate func doReconnect(){
        
        
        let delay = DispatchTime.now() + Double(Int64(self.reconnectDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        self.reconnectTaskQueue.asyncAfter(deadline: delay){
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
    @objc public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!){
        _ = self.processResponse(connectionInfo.connection, message: message as! String)
    }
    
    public func webSocketDidOpen(_ webSocket: SRWebSocket!){
        if self.connectionInfo.connection.changeState(.reconnecting, newState: .connected) == true{
           self.connectionInfo.connection.onReconnected()
        }
    }
    public func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!){
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
    public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool){
        
        if self.connectionInfo.disconnectToken.isCancelling{
            return
        }
        
        if abortHandler.TryCompleteAbort(){
            return
        }
        
        doReconnect()
        
    }
    public func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!){
        
    }
}
