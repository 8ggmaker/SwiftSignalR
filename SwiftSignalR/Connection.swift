//
//  File.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/26.
//  Copyright © 2016年 zsy. All rights reserved.
//

import Foundation
open class Connection: IConnection{
    
    static let defaultAbortTimeout = TimeInterval(30)
    
    fileprivate var assemblyVersion: Version! = nil
    
    fileprivate let receiveMessageQueue = DispatchQueue(label: "swiftsignalR.receivemessage", attributes: [])
    
    fileprivate let stateLock = SSRLock()
    
    fileprivate let startLock = SSRLock()
    
    fileprivate var heartBeatMonitor: HeartBeatMonitor! = nil
    
    fileprivate var disconnectCts: CancellationSource! = nil
    
    fileprivate var connectionData: String = ""
    
    open var clientProtocol: Version = Version()
    
    open var transportConnectTimeout: TimeInterval = TimeInterval(0)
    
    fileprivate var disconnectTimeout: TimeInterval = TimeInterval(0)
    
    open var totalTransportConnectTimeout: TimeInterval = TimeInterval(0)
    
    open var reconnectWindow: TimeInterval = TimeInterval(0)
    
    open var keepAliveData: KeepAliveData? = nil
    
    open var messageId:String? = ""
    
    open var groupsToken:String? = ""
    
    open var items:NSMutableDictionary = NSMutableDictionary()
    
    open var connectionId: String = ""
    
    open var connectionToken: String? = ""
    
    open var url: String = ""
    
    open var queryString: String? = ""
    
    open var state: ConnectionState = .disconnected
    
    open var transport: IClientTransport! = nil
    
    open var lastMessageAt: Date = Date()
    
    
    open var lastActiveAt: Date = Date()
    
    
    open var headers: NSMutableDictionary = NSMutableDictionary()
    
    open var credentials: URLCredential{
        get{
            fatalError("must override")

        }
        set{
            fatalError("must override")

        }
    }
    
    
    //MARK: CALL BACK ACTIONS
    
    open var started: (() -> ())? = nil
    
    open var closed: (() -> ())? = nil
    
    open var received: ((Any?) throws -> ())? = nil
    
    open var error: ((Error?) -> ())? = nil
    
    open var reconnecting: (() -> ())? = nil
    
    open var reconnected: (() -> ())? = nil
    
    open var connectionSlow: (() -> ())? = nil
    
    
    public  convenience init(url:String) throws{
        try self.init(url:url,queryString: "")
    }
    
    public  convenience init(url:String,queryString:Dictionary<String,String>)throws {
        try self.init(url:url,queryString: Connection.createQueryString(queryString))
    }
    
    
    public init(url:String,queryString:String) throws{
        
        if url.isEmpty == true{
            throw CommonException.argumentNullException(exception: "url")
        }
        if url.contains("?"){
            throw CommonException.invalidArgumentException(exception: "url")
        }
        
        self.url = url
        if self.url.characters.last != "/"{
            self.url += "/"
        }
        
        self.queryString = queryString
        self.lastActiveAt = Date()
        self.lastMessageAt = Date()
        self.reconnectWindow = 0
        self.items = NSMutableDictionary()
        self.state = .disconnected
        self.headers = NSMutableDictionary()
        self.transportConnectTimeout = 0
        self.clientProtocol = try Version(major: 1, minor: 4)
    }
    
    
    open func start() throws{
        try start(HttpClient())
    }
    
    open func start(_ httpClient:IHttpClient) throws {
        // currently support websocket only
        try start(WebSocketTransport(httpClient: httpClient))
    }
    
    open func start(_ transport:IClientTransport)throws {
        
        try startLock.calculateLockedOrFail({
            
            () -> Void in
            
            if self.changeState(.disconnected, newState: .connecting) == false{
                return
            }
            
            self.disconnectCts = CancellationSource()
            self.transport = transport
            
            self.negotiate(transport)
        })
        
    }
    
    
    fileprivate func negotiate(_ transport:IClientTransport){
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
                    
                    var beatInterval = TimeInterval(5)
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
    
    fileprivate func startTransport(){
        transport.start(self, connectionData: connectionData, disconnectToken: disconnectCts.token){
            err -> () in
            if err == nil{
                self.changeState(.connecting, newState: .connected)
                
                if self.started != nil{
                    self.started!()
                }
                self.lastActiveAt = Date()
                
                self.lastMessageAt = Date()
                
                self.heartBeatMonitor.start()
            }else{
                self.onError(err!)
                self.stop()
            }
        }
    }
    
    open func changeState(_ oldState:ConnectionState,newState:ConnectionState) -> Bool{
        
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
    
    fileprivate func verifyProtocolVersion(_ versionStr:String)throws {
        var version: Version = Version()
        if versionStr.isEmpty == true || Version.tryParse(versionStr, version:&version) == false || version.isEqual(self.clientProtocol) == false{
            throw CommonException.invalidArgumentException(exception: "versionStr")
        }
    }
    open func stop(){
        self.stop(Connection.defaultAbortTimeout)
    }
    
    
    open func stop(_ error:Error?){
        self.stop(error,timeout: Connection.defaultAbortTimeout)
    }
    
    
    open func stop(_ error:Error?,timeout:TimeInterval){
        if error != nil{
            self.onError(error!)
        }
        self.stop(timeout)
    }
    
    open func stop(_ timeout:TimeInterval){
        do {
            var alreadyStopped = false
            try startLock.calculateLockedOrFail({
                () -> Void in
                if self.state == .disconnected{
                    alreadyStopped = true
                    return
                }})
            if !alreadyStopped{
                try self.transport.abort(self, timeout: timeout, connectionData: self.connectionData)
                self.disconnect()
            }
            
            
        }catch{
            
        }
    }
    open func disconnect(){
        // currently connect task has completed or failed
        stateLock.calculateLocked({
            () -> Void in
            if self.state != .disconnected{
                self.state = .disconnected
                
                if self.disconnectCts != nil{
                    self.disconnectCts.cancel()
                    self.disconnectCts.dispose()
                    self.disconnectCts = nil
                }
                
                
                if self.heartBeatMonitor != nil{
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

            }
        })
        self.onClosed()
        
    }
    
    open func send(_ data:String, completionHandler:((_ response:Any?,_ error:Error?)->())?){
        var error: Error? = nil
        if state == .disconnected{
            error = CommonException.invalidOperationException(exception: "Data cannot be sent, connection disconnected")
            if completionHandler != nil{
                completionHandler!(nil,error)
            }
            return
        }
        
        if state == .connecting{
            error = CommonException.invalidOperationException(exception: "Data cannot be sent, connection connecting")
            if completionHandler != nil{
                completionHandler!(nil, error)
            }
            return
        }
        
        transport.send(self, data: data, connectionData: connectionData, completionHandler: completionHandler)
        
    }
    
    
    open func send(_ data:AnyObject,completionHandler:((_ response:Any?,_ error:Error?)->())?){
        do{
            if let dataStr = try JsonSerialize(data){
                send(dataStr, completionHandler: completionHandler)
            }
        }catch let err{
            if completionHandler != nil{
                completionHandler!(nil, err)
            }
        }
    }
    
    
    //MARK: ON EVENT
    
    func onClosed(){
        if closed != nil{
            closed!()
        }
    }
    
    open func onReceived(_ data: Any?){
        receiveMessageQueue.async{
            do{
                try self.onMessageReceived(data)
            }catch let err{
                self.onError(err)
            }
        }
    }
    
    
    func onMessageReceived(_ message:Any?)throws {
        if received != nil{
            do{
                try received!(message)
            }catch let err{
                onError(err)
            }
        }
    }
    open func onError(_ error:Error){
        SSRLog.log(error,message: nil)
        if self.error != nil{
            self.error!(error)
        }
    }
    
    open func onReconnecting(){
        SSRLog.log(nil, message: "reconnecting")

        let delayTimeout = DispatchTime.now() + Double(Int64(self.disconnectTimeout * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTimeout){
            if self.state == .connected{// do nothing, connection resume
                return
            }
            self.onError(CommonException.timeoutException(exception: "reconnct timeout"))
            self.disconnect()
        }
        
        if reconnecting != nil{
            reconnecting!()
        }
    }
    
    open func onReconnected(){
        
        SSRLog.log(nil, message: "reconnected")
        if reconnected != nil{
            reconnected!()
        }
        
        heartBeatMonitor.Reconnected()
        markLastMessage()
    }
    
    
    open func onConnectionSlow(){
        SSRLog.log(nil,message: "connection slow")
        
        if connectionSlow != nil{
            connectionSlow!()
        }
    }
    
    open func markLastMessage(){
        self.lastMessageAt = Date()
    }
    
    open func markActive(){
        do{
            if try TransportHelper.verifyLastActive(self) == true{
                self.lastActiveAt = Date()
            }
        }catch let err{
            onError(err)
        }
    }
    
    func onSending() -> String{
        return ""
    }
    
    
    //MARK: PREPAREREQUEST
    open func prepareRequest(_ request:URLRequest)-> URLRequest{
        var mutableReq = request
        #if os(iOS)
            mutableReq.addValue(createUserAgentString("SignalR.Client.Swift.iOS"), forHTTPHeaderField: "User-Agent")
        #elseif os(OSX)
            mutableReq.addValue(createUserAgentString("SignalR.Client.Swift.OSX"), forHTTPHeaderField: "User-Agent")
        #endif
        
        _ = headers.map{
            key,value -> Void in
            mutableReq.addValue(value as! String, forHTTPHeaderField: key as! String)
        }
        
        return mutableReq
    }
    
    fileprivate func createUserAgentString(_ client:String)-> String{
        do{
            if assemblyVersion == nil{
                assemblyVersion = try Version(major: 2, minor: 2, build: 1)
            }
            #if os(iOS)
                let systemVersion = UIDevice.current.systemVersion
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
    
    static func createQueryString(_ queryString:Dictionary<String,String>)-> String{
        var query = queryString.map{
            key,value -> String in
            return "\(key)=\(value)"
            }.reduce("", {
                initialStr,str -> String in
                return initialStr + str + "&"
            })
        assert(query.isEmpty == false)
        assert(query.characters.last == "&")
        query.remove(at: query.characters.index(query.endIndex, offsetBy: -1))
        return query
    }
    
    
    //MARK: JSON OPERATION
    
    open var JsonDeSerialize: ((String)throws -> AnyObject? ) = {
        str throws -> AnyObject? in
        if let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false){
            if let json = try? JSONSerialization.jsonObject(with: data, options: []){
                return json as AnyObject?
            }
        }
        return nil
    }
    
    open var JsonSerialize: ((AnyObject)throws -> String?) = {
        anyObj throws -> String? in
        
        if let obj = try JsonSerializer.generateValidJsonObject(anyObj){
            if let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions()){
                if let res = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String{
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
