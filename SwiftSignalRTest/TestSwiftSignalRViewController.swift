//
//  TestSwiftSignalRViewController.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import UIKit
import SwiftSignalR

class TestSwiftSignalRViewController: UIViewController {

    private var connection: Connection! = nil
    
    private var button: UIButton! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.button = UIButton(frame:CGRect(x:50,y:50,width: 100,height: 100))
        self.button.backgroundColor = UIColor.redColor()
        self.button.addTarget(self, action: #selector(press), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.button)
    }
    
    func press(){
        do{
            try connection = Connection(url: "https://swiftsignalrtest.azurewebsites.net/echo")
            connection.started = {
                self.connection.send("test from ios client", completionHandler: {
                    (_,_) in
                })
                print("started")
            }
            
            connection.received = {
                msg in
                if msg is String{
                    print(msg as! String)
                }
            }
            
            try connection.start()
            
        }catch let err{
            print(err)
            
        }

    }
}
