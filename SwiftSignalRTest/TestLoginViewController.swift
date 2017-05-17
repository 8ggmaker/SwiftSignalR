//
//  TestLoginViewController.swift
//  SwiftSignalR
//
//  Created by zsy on 17/1/7.
//  Copyright © 2017年 zsy. All rights reserved.
//

import UIKit
import SwiftSignalR
class TestLoginViewController: UIViewController {
    
    fileprivate var nameInput: UITextField!
    
    fileprivate var loginBtn: UIButton!
    
    fileprivate var connection: HubConnection! = nil
    
    fileprivate var testHubProxy: HubProxy! = nil

    static let NewMessage = Notification.Name("NewMessage")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setup(){
        nameInput = UITextField()
        nameInput.delegate = self
        nameInput.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        nameInput.borderStyle = .line
        nameInput.placeholder = "Input your name"
        
        self.view.addSubview(nameInput)
        
        loginBtn = UIButton()
        loginBtn.setTitle("Login", for: UIControlState())
        loginBtn.backgroundColor = UIColor.green.withAlphaComponent(0.6)
        loginBtn.sizeToFit()
        loginBtn.addTarget(self, action: #selector(start), for: .touchUpInside)
        
        self.view.addSubview(loginBtn)
        
        self.buildConstraints()
        self.view.backgroundColor = UIColor.white
    }
    
    fileprivate func buildConstraints(){
        self.nameInput.translatesAutoresizingMaskIntoConstraints = false
        self.loginBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: -80))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: -150))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 35))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .top, relatedBy: .equal, toItem: self.nameInput, attribute: .bottom, multiplier: 1.0, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .width, relatedBy: .equal, toItem: self.nameInput, attribute: .width, multiplier: 1.0, constant: 0.0))
    }
    
    func start(){
        do{
            if nameInput.text == nil || (nameInput.text?.isEmpty)!{
                return
            }
            loginBtn.isEnabled = false
            
            connection = try HubConnection(url: "https://swiftsignalrtest.azurewebsites.net")
            testHubProxy = connection.createHubProxy("TestHub") as? HubProxy
            testHubProxy.on("onNewMessage", action: {
                args -> () in
                if args == nil || (args?.count)! < 2{
                    return
                }
                let user = args![0] as! String!
                let msg = args![1] as! String!
                print("\(user): \(msg)")
                NotificationCenter.default.post(name:TestLoginViewController.NewMessage,object:["sender":user,"msg":msg])

            })
            
            connection.started = {
                print("started")
                DispatchQueue.main.async{
                    self.loginBtn.isEnabled = true

                    let chatController = TestSwiftSignalRViewController()
                    chatController.delegate = self
                    chatController.userName = self.nameInput.text!
                    self.present(chatController, animated: true, completion: nil)
                }
                
            }
            
            connection.closed = {
                do{
                    try self.connection.start()

                }catch{
                    
                }
            }
            
            try connection.start()
            
        }catch let err{
            print(err)
            loginBtn.isEnabled = true
            
        }
        
    }
    
    func send(_ user:String,msg:String,compeletionHandler:@escaping ((Bool)->())){
        testHubProxy.invoke("SendMessage", params: [user as Optional<AnyObject>,msg as Optional<AnyObject>], completionHandler: {
            (res,err) -> () in
            if err != nil{
                print(err!)
            }
            
            if res is Bool{
                compeletionHandler(res as! Bool)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


extension TestLoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return true
    }

}
