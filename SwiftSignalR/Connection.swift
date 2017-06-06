//
//  File.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/26.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
public class Connection: IConnection{
    
    static let defaultAbortTimeout = NSTimeInterval(30)
    
    private var assemblyVersion: Version! = nil
    
    private let receiveMessageQueue = dispatch_queue_create("swiftsignalR.receivemessage", nil)
    
    private let stateLock = SSRLock()
    
    private let startLock = SSRLock()
    
    private var heartBeatMonitor: HeartBeatMonitor! = nil
    
    private var disconnectCts: CancellationSource! = nil
    
    private var connectionData: String = ""
    
    public var clientProtocol: Version = Version()
    
    public var transportConnectTimeout: NSTimeInterval = NSTimeInterval(0)
    
    private var disconnectTimeout: NSTimeInterval = NSTimeInterval(0)
    
    public var totalTransportConnectTimeout: NSTimeInterval = NSTimeInterval(0)
    
    public var reconnectWindow: NSTimeInterval = NSTimeInterval(0)
    
    public var keepAliveData: KeepAliveData? = nil
    
    public var messageId:String? = ""
    
    public var groupsToken:String? = ""
    
    public var items:NSMutableDictionary = NSMutableDictionary()
    
    public var connectionId: String = ""
    
    public var connectionToken: String? = ""
    
    public var url: String = ""
    
    public var queryString: String? = ""
    
    public var state: ConnectionState = .Disconnected
    
    public var transport: IClientTransport! = nil
    
    public var lastMessageAt: NSDate = NSDate()
    
    
    public var lastActiveAt: NSDate = NSDate()
    
    
    public var headers: NSMutableDictionary = NSMutableDictionary()
    
    public var credentials: NSURLCredential{
        get{
            fatalError("must override")

        }
        set{
            fatalError("must override")

        }
    }
    
    public var connectingMessageBuffer: ConnectingMessageBuffer!
    
    
    //MARK: CALL BACK ACTIONS
    
    public var started: (() -> ())? = nil
    
    public var closed: (() -> ())? = nil
    
    public var received: (Any? -> ())? = nil
    
    public var error: (ErrorType? -> ())? = nil
    
    public var reconnecting: (() -> ())? = nil
    
    public var reconnected: (() -> ())? = nil
    
    public var connectionSlow: (() -> ())? = nil
    
    
    public  convenience init(url:String) throws{
        try self.init(url:url,queryString: "")
    }
    
    public  convenience init(url:String,queryString:Dictionary<String,String>)throws {
        try self.init(url:url,queryString: Connection.createQueryString(queryString))
    }
    
    
    public init(url:String,queryString:String) throws{
        
        if url.isEmpty == true{
            throw CommonException.ArgumentNullException(exception: "url")
        }
        if url.containsString("?"){
            throw CommonException.InvalidArgumentException(exception: "url")
        }
        
        self.url = url
        if self.url.characters.last != "/"{
            self.url += "/"
        }
        
        self.queryString = queryString
        self.lastActiveAt = NSDate()
        self.lastMessageAt = NSDate()
        self.reconnectWindow = 0
        self.items = NSMutableDictionary()
        self.state = .Disconnected
        self.headers = NSMutableDictionary()
        self.transportConnectTimeout = 0
        self.clientProtocol = try Version(major: 1, minor: 4)

    }
    
    
    public func start() throws{
        try start(HttpClient())
    }
    
    public func start(httpClient:IHttpClient) throws {
        // currently support websocket only
        try start(WebSocketTransport(httpClient: httpClient))
    }
    
    public func start(transport:IClientTransport)throws {
        
        try startLock.calculateLockedOrFail({
            
            () -> Void in
            
            if self.changeState(.Disconnected, newState: .Connecting) == false{
                return
            }
            
            if self.connectingMessageBuffer == nil{
                self.connectingMessageBuffer = ConnectingMessageBuffer(connection: self,drainCallback:{
                    [unowned self] data->() in
                    
                    self.onMessageReceived(data)
                })
            }
        
            self.disconnectCts = CancellationSource()
            self.transport = transport
            
            self.negotiate(transport)
        })
        
    }
    
    
    private func negotiate(transport:IClientTransport){
        connectionData = onSending()
        transport.negotiate(self, connectionData: connectionData){
            err,response -> () in
            if err == nil{
                do{
                    try self.verifyProtocolVersion(response!.protocolVersion)
                    
                    self.connectionId = response!.connectionId
                    self.connectionToken = response!.connectionToken
                    self.disconnectTimeout = response!.disconnectTimeout
                    self.totalTransportConnectTimeout = response!.transportConnectTimeout + self.transportConnectTimeout
                    
                    var beatInterval = NSTimeInterval(5)
                    if response!.keepAliveTimeout != nil{
                        self.keepAliveData = KeepAliveData(timeout: response!.keepAliveTimeout!)
                        self.reconnectWindow = self.disconnectTimeout + (self.keepAliveData?.timeout)!
                        
                        beatInterval = (self.keepAliveData?.checkInterval)!
                    }else{
                        self.reconnectWindow = self.disconnectTimeout
                    }
                    
                    self.heartBeatMonitor = HeartBeatMonitor(connection: self, connectionStateLock: self.stateLock, beatInterval: beatInterval)
                    
                    self.startTransport()
                }catch{
                    
                }
            }else{
                self.onError(err!)
                self.stop()
            }
            
            
        }
    }
    
    private func startTransport(){
        transport.start(self, connectionData: connectionData, disconnectToken: disconnectCts.token){
            err -> () in
            if err == nil{
                self.changeState(.Connecting, newState: .Connected)
                
                if self.connectingMessageBuffer != nil{
                    self.connectingMessageBuffer.drain()
                }
                
                if self.started != nil{
                    self.started!()
                }
                self.lastActiveAt = NSDate()
                
                self.lastMessageAt = NSDate()
                
                self.heartBeatMonitor.start()
            }else{
                self.onError(err!)
                self.stop()
            }
        }
    }
    
    public func changeState(oldState:ConnectionState,newState:ConnectionState) -> Bool{
        
        let res:Bool = stateLock.calculateLocked({
            () -> Bool in
            if self.state == oldState{
                self.state = newState
                return true
            }
            
            return false
        })
        
        return res
        
    }
    
    private func verifyProtocolVersion(versionStr:String)throws {
        var version: Version = Version()
        if versionStr.isEmpty == true || Version.tryParse(versionStr, version:&version) == false || version.isEqual(self.clientProtocol) == false{
            throw CommonException.InvalidArgumentException(exception: "versionStr")
        }
    }
    public func stop(){
        self.stop(Connection.defaultAbortTimeout)
    }
    
    
    public func stop(error:ErrorType?){
        self.stop(error,timeout: Connection.defaultAbortTimeout)
    }
    
    
    public func stop(error:ErrorType?,timeout:NSTimeInterval){
        if error != nil{
            self.onError(error!)
        }
        self.stop(timeout)
    }
    
    public func stop(timeout:NSTimeInterval){
        do {
            var alreadyStopped = false
            try startLock.calculateLockedOrFail({
                () -> Void in
                if self.state == .Disconnected{
                    alreadyStopped = true
                    return
                }
            })
            if !alreadyStopped{
                try self.transport.abort(self, timeout: timeout, connectionData: self.connectionData)
                self.disconnect()
            }
            
            
        }catch{
            
        }
    }
    public func disconnect(){
        // currently connect task has completed or failed
        stateLock.calculateLocked({
            () -> Void in
            if self.state != .Disconnected{
                self.state = .Disconnected
                
                if self.disconnectCts != nil{
                    self.disconnectCts.cancel()
                    self.disconnectCts.dispose()
                    self.disconnectCts = nil
                }
                
                
                if self.heartBeatMonitor != nil{
                    self.heartBeatMonitor.stop()
                    self.heartBeatMonitor = nil
                }
                
                if self.transport != nil{
                    self.transport = nil
                }
                
                self.connectionId = ""
                self.connectionToken = ""
                self.groupsToken = ""
                self.messageId = ""
                self.connectionData = ""
                if self.connectingMessageBuffer != nil{
                    self.connectingMessageBuffer.clear()
                }
                self.onClosed()
            }
        })
        
    }
    
    public func send(data:String, completionHandler:((response:Any?,error:ErrorType?)->())?){
        var error: ErrorType? = nil
        if state == .Disconnected{
            error = CommonException.InvalidOperationException(exception: "Data cannot be sent, connection disconnected")
            if completionHandler != nil{
                completionHandler!(response: nil,error: error)
            }
            return
        }
        
        if state == .Connecting{
            error = CommonException.InvalidOperationException(exception: "Data cannot be sent, connection connecting")
            if completionHandler != nil{
                completionHandler!(response: nil, error: error)
            }
            return
        }
        
        transport.send(self, data: data, connectionData: connectionData, completionHandler: completionHandler)
        
    }
    
    
    public func send(data:AnyObject,completionHandler:((response:Any?,error:ErrorType?)->())?){
        do{
            if let dataStr = try JsonSerialize(data){
                send(dataStr, completionHandler: completionHandler)
            }
        }catch let err{
            if completionHandler != nil{
                completionHandler!(response: nil, error: err)
            }
        }
    }
    
    
    //MARK: ON EVENT
    
    func onClosed(){
        if closed != nil{
            closed!()
        }
    }
    
    public func onReceived(data: Any?){
        dispatch_sync(receiveMessageQueue){
            self.onMessageReceived(data)
        }
    }
    
    
    func onMessageReceived(message:Any?) {
        if received != nil{
            received!(message)
        }
    }
    public func onError(error:ErrorType){
        SSRLog.log(error,message: nil)
        if self.error != nil{
            self.error!(error)
        }
    }
    
    public func onReconnecting(){
        SSRLog.log(nil, message: "reconnecting")

        let delayTimeout = dispatch_time(DISPATCH_TIME_NOW, Int64(self.disconnectTimeout * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(delayTimeout, dispatch_get_main_queue()){
            if self.state == .Connected{// do nothing, connection resume
                return
            }
            self.onError(CommonException.TimeoutException(exception: "reconnct timeout"))
            self.disconnect()
        }
        
        if reconnecting != nil{
            reconnecting!()
        }
    }
    
    public func onReconnected(){
        
        SSRLog.log(nil, message: "reconnected")
        if reconnected != nil{
            reconnected!()
        }
        
        heartBeatMonitor.Reconnected()
        markLastMessage()
    }
    
    
    public func onConnectionSlow(){
        SSRLog.log(nil,message: "connection slow")
        
        if connectionSlow != nil{
            connectionSlow!()
        }
    }
    
    public func markLastMessage(){
        self.lastMessageAt = NSDate()
    }
    
    public func markActive(){
        do{
            if try TransportHelper.verifyLastActive(self) == true{
                self.lastActiveAt = NSDate()
            }
        }catch let err{
            onError(err)
        }
    }
    
    func onSending() -> String{
        return ""
    }
    
    
    //MARK: PREPAREREQUEST
    public func prepareRequest(request:NSMutableURLRequest)-> NSMutableURLRequest{
        #if os(iOS)
            request.addValue(createUserAgentString("SignalR.Client.Swift.iOS"), forHTTPHeaderField: "User-Agent")
        #elseif os(OSX)
            request.addValue(createUserAgentString("SignalR.Client.Swift.OSX"), forHTTPHeaderField: "User-Agent")
        #endif
        
        headers.map{
            key,value -> Void in
            request.addValue(value as! String, forHTTPHeaderField: key as! String)
        }
        
        return request
    }
    
    private func createUserAgentString(client:String)-> String{
        do{
            if assemblyVersion == nil{
                assemblyVersion = try Version(major: 2, minor: 2, build: 1)
            }
            #if os(iOS)
                let systemVersion = UIDevice.currentDevice().systemVersion
                return "\(client)/\(assemblyVersion) (\(systemVersion))"
            #elseif os(OSX)
                var environmentVersion = "";
                if NSProcessInfo.processInfo().operatingSystem() == NSMACHOperatingSystem {
                    environmentVersion += "Mac OS X"
                    var version = NSProcessInfo.processInfo().operatingSystemVersionString
                    version.rangeOfString("Version") != nil{
                        environmentVersion += version
                    }
                    return "\(client)/\(assemblyVersion) (\(enviromentVersion))"
                }
                return "\(client)/(\(assemblyVersion)"
            #endif
        }catch{
            
        }
        return "\(client)"
    }
    
    static func createQueryString(queryString:Dictionary<String,String>)-> String{
        var query = queryString.map{
            key,value -> String in
            return "\(key)=\(value)"
            }.reduce("", combine: {
                initialStr,str -> String in
                return initialStr + str + "&"
            })
        assert(query.isEmpty == false)
        assert(query.characters.last == "&")
        query.removeAtIndex(query.endIndex.advancedBy(-1))
        return query
    }
    
    
    //MARK: JSON OPERATION
    
    public var JsonDeSerialize: ((String)throws -> AnyObject? ) = {
        str throws -> AnyObject? in
        if let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []){
                return json
            }
        }
        return nil
    }
    
    public var JsonSerialize: ((AnyObject)throws -> String?) = {
        anyObj throws -> String? in
        
        if let obj = try JsonSerializer.generateValidJsonObject(anyObj){
            if let jsonData = try? NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions()){
                if let res = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String{
//                    let range = res.startIndex.advancedBy(1) ..< res.endIndex.advancedBy(-1)
                    return res
                }
            }
        }
        
        return nil
    }
    
    //MARK: deinit
    deinit{
        stop()
    }
    
}