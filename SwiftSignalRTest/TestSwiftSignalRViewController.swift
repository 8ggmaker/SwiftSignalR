//
//  TestSwiftSignalRViewController.swift
//  SwiftSignalR
//
//  Created by zsy on 16/12/29.
//  Copyright © 2016年 zsy. All rights reserved.
//

import UIKit
import SwiftSignalR
import JSQMessagesViewController

class TestSwiftSignalRViewController: JSQMessagesViewController {

    private var messages = [JSQMessage]()
    
    weak var delegate:TestLoginViewController! = nil
    
    var userName: String = ""
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = userName
        self.senderDisplayName = userName
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TestLoginViewController.NewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TestSwiftSignalRViewController.newMessage(_:)), name: TestLoginViewController.NewMessage, object: nil)
    }
}
extension TestSwiftSignalRViewController{
    func newMessage(notification:NSNotification){
        let user = notification.userInfo!["sender"] as? String
        let msg = notification.userInfo!["msg"] as? String
        
        dispatch_async(dispatch_get_main_queue()){
            if user != self.userName{
                let jsqMsg = JSQMessage(senderId: user, displayName: user, text: msg)
                self.messages.append(jsqMsg)
                self.finishReceivingMessage()
            }
        }
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        self.delegate.send(userName, msg: text){
            res -> () in
            if res{
                dispatch_async(dispatch_get_main_queue()){
                    let message = JSQMessage(senderId: self.userName, senderDisplayName: self.userName, date: date, text: text)
                    self.messages.append(message)
                    self.finishSendingMessage()
                }
                
            }else{
                print("send failed")
            }
            
        }
        
    }
}


extension TestSwiftSignalRViewController{
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        switch message.senderId {
        case self.userName:
            return NSAttributedString(string: "Me")
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
            
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 15 //or what ever height you want to give
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

}
