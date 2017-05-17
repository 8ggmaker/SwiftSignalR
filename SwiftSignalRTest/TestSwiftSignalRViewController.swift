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

    fileprivate var messages = [JSQMessage]()
    
    weak var delegate:TestLoginViewController! = nil
    
    var userName: String = ""
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = userName
        self.senderDisplayName = userName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: TestLoginViewController.NewMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TestSwiftSignalRViewController.newMessage(_:)), name: TestLoginViewController.NewMessage, object: nil)
    }
}
extension TestSwiftSignalRViewController{
    func newMessage(_ notification:Notification){
        if let objDic = notification.object as? [String:Any]{
            let user = objDic["sender"] as? String
            let msg = objDic["msg"] as? String
            
            DispatchQueue.main.async{
                if user != self.userName{
                    let jsqMsg = JSQMessage(senderId: user, displayName: user, text: msg)
                    self.messages.append(jsqMsg!)
                    self.finishReceivingMessage()
                }
            }
        }

    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        self.delegate.send(userName, msg: text){
            res -> () in
            if res{
                DispatchQueue.main.async{
                    let message = JSQMessage(senderId: self.userName, senderDisplayName: self.userName, date: date, text: text)
                    self.messages.append(message!)
                    self.finishSendingMessage()
                }
                
            }else{
                print("send failed")
            }
            
        }
        
    }
}


extension TestSwiftSignalRViewController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15 //or what ever height you want to give
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

}
