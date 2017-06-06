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
    
    private var nameInput: UITextField!
    
    private var loginBtn: UIButton!
    
    private var connection: HubConnection! = nil
    
    private var testHubProxy: HubProxy! = nil

    static let NewMessage = "NewMessage"

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
        nameInput.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        nameInput.borderStyle = .Line
        nameInput.placeholder = "Input your name"
        
        self.view.addSubview(nameInput)
        
        loginBtn = UIButton()
        loginBtn.setTitle("Login", forState: .Normal)
        loginBtn.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.6)
        loginBtn.sizeToFit()
        loginBtn.addTarget(self, action: #selector(start), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(loginBtn)
        
        self.buildConstraints()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    private func buildConstraints(){
        self.nameInput.translatesAutoresizingMaskIntoConstraints = false
        self.loginBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -80))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: -150))
        self.view.addConstraint(NSLayoutConstraint(item: self.nameInput, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 35))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .Top, relatedBy: .Equal, toItem: self.nameInput, attribute: .Bottom, multiplier: 1.0, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: self.loginBtn, attribute: .Width, relatedBy: .Equal, toItem: self.nameInput, attribute: .Width, multiplier: 1.0, constant: 0.0))
    }
    
    func start(){
        do{
            if nameInput.text == nil || (nameInput.text?.isEmpty)!{
                return
            }
            loginBtn.enabled = false
            
            connection = try HubConnection(url: "https://swiftsignalrtest.azurewebsites.net")
            testHubProxy = connection.createHubProxy("TestHub") as? HubProxy
            testHubProxy.on("onNewMessage", action: {
                args -> () in
                if args == nil || args?.count < 2{
                    return
                }
                let user = args![0] as! String!
                let msg = args![1] as! String!
                print("\(user): \(msg)")
                NSNotificationCenter.defaultCenter().postNotificationName(TestLoginViewController.NewMessage, object: nil, userInfo: ["sender":user,"msg":msg])
            })
            
            connection.started = {
                print("started")
                dispatch_async(dispatch_get_main_queue()){
                    self.loginBtn.enabled = true

                    let chatController = TestSwiftSignalRViewController()
                    chatController.delegate = self
                    chatController.userName = self.nameInput.text!
                    self.presentViewController(chatController, animated: true, completion: nil)
                }
                
            }
            
            connection.closed = {
                do{
                    self.start()

                }catch{
                    
                }
            }
            
            try connection.start()
            
        }catch let err{
            print(err)
            loginBtn.enabled = true
            
        }
        
    }
    
    func send(user:String,msg:String,compeletionHandler:(Bool->())){
        testHubProxy.invoke("SendMessage", params: [user,msg], completionHandler: {
            (res,err) -> () in
            if err != nil{
                print(err!)
            }
            
            if res is Bool{
                compeletionHandler(res as! Bool)
            }else{
                compeletionHandler(false)
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
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        return true
    }

}
