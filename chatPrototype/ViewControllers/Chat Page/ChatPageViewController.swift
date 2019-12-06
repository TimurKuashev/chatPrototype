//
//  ChatPageViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import Firebase

final class ChatPageViewController: UIViewController {
    
    // MARK: - @IBOutlet & Private Properties
    @IBOutlet private var lblConversationName: UILabel!
    @IBOutlet private var btnOptions: UIButton!
    @IBOutlet private var dialogView: DialogView!
    @IBOutlet private var dialogBottomPanel: DialogBottomPanelView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    var chatPartnerId: String? {
        get { dialogView.chatPartnerId }
        set { dialogView.chatPartnerId = newValue }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Private Methods
private extension ChatPageViewController {
    
    func initialConfigure() {
        btnOptions.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        dialogBottomPanel.delegate = self
    }
    
    @objc private func openSettings(_ sender: UIButton?) {
        
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        
    }
    
}

// MARK: - DialogBottomPanelViewDelegate
extension ChatPageViewController: DialogBottomPanelViewDelegate {
    
    func attachFile() {
        
    }
    
    func send(message: String?) {
        guard let message = message else {
            return
        }
        
        var data: Dictionary<String, Any> = [
            "createdAt": NSDate().timeIntervalSince1970.description,
            "sender": FirebaseAuthService.getUserId() ?? "!!!Error!!!",
            "text": message,
            "type": "text"
        ]
//        FirebaseDataWritter.writeToRealtimeDatabase(data: &data, toCollection: FirebaseTableNames.messages)
        let childRef = Database.database().reference().child(FirebaseTableNames.messages).child(FirebaseAuthService.getUserId()!).childByAutoId()
        childRef.updateChildValues(data)
        
        data.removeAll()
        data["createdAt"] = Date().timeIntervalSince1970.description
        let tempData = [
            "0": FirebaseAuthService.getUserId(),
            "1": self.chatPartnerId!
        ]
        data["participants"] = tempData
//        let conversationsRef = Database.database().reference().child(FirebaseTableNames.conversations).child(FirebaseAuthService.getUserId()!).child(childRef.key!)
        // TODO: В общем, сейчас идёт обновление данных. Потом надо сделать так, что бы мы бежали по массиву с conversations и при помощи "0" и "1" поля проверяли, нет ли у нас уже этотго. Крч чекаем, существует ли чат с этим человеком
        // Если у нас нет такого conversations, значит мы пушим новый. Только используем УНИКАЛЬНЫЙ (childByAutoId или как его там), а потом этот же уникальный пересылаем в users-converstaions
        let conversationsRef = Database.database().reference().child(FirebaseTableNames.conversations).child(FirebaseAuthService.getUserId()!)
        conversationsRef.setValue(data)
        let userConversationsRef = Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(FirebaseAuthService.getUserId()!)
        userConversationsRef.setValue(1)
        
        let anotherConverstaionsRef = Database.database().reference().child(FirebaseTableNames.conversations).child(chatPartnerId!)
        anotherConverstaionsRef.setValue(1)
        let anotherUserConversationsRef = Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(chatPartnerId!)
        anotherUserConversationsRef.setValue(1)
        
//        FirebaseDataWritter.updateDataToRealtimeDatabase(data: &data, toCollection: FirebaseTableNames.conversations)
        // ЧТО БЫ ВЫГРУЗИТЬ СООБЩЕНИЯ, МЫ ДОЛЖНЫ ГДЕ-ТО СОХРАНИТЬ ЭТОТ childByAutoId, ПОТОМ ПРИ ЕГО ПОМОЩИ ВЫГРУЗИТЬ users-conversations --> conversations --> "0" и "1" поля?

    }
    
    func recordVoiceMessage() {
        
    }
    
}
