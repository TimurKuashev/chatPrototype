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
    
    // MARK: - @IBOutlet  Private Properties
    @IBOutlet private var lblConversationName: UILabel!
    @IBOutlet private var btnOptions: UIButton!
    @IBOutlet private var dialogView: DialogView!
    @IBOutlet private var dialogBottomPanel: DialogBottomPanelView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    var chatPartnerId: String?
    
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
        dialogView.chatPartnerId = self.chatPartnerId
        self.navigationItem.title = ""
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

        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
    }
    
}

// MARK: - DialogBottomPanelViewDelegate
extension ChatPageViewController: DialogBottomPanelViewDelegate {
    
    func attachFile() {
        
    }
    
    func send(message: String?) {
        guard let message = message, let myUid = FirebaseAuthService.getUserId() else {
            return
        }
        // Messages
        var data: Dictionary<String, Any> = [
            "createdAt": NSDate().timeIntervalSince1970.description,
            "sender": FirebaseAuthService.getUserId() ?? "!!!Error!!!",
            "text": message,
            "type": "text"
        ]
        Database.database().reference().child(FirebaseTableNames.messages).child(myUid).childByAutoId().updateChildValues(data)
        
        // Conversations
        let conversationsRef = Database.database().reference().child(FirebaseTableNames.conversations).child(myUid).childByAutoId()
        data.removeAll()
        data["createdAt"] = Date().timeIntervalSince1970.description
        let tempData = [
            "0": FirebaseAuthService.getUserId(),
            "1": self.chatPartnerId!
        ]
        data["participants"] = tempData
        conversationsRef.setValue(data)
        
        // Users_Conversations
        let userConversationsRef = Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).childByAutoId()
        data.removeAll()
        data = [
            "conversation_id": conversationsRef.key!,
            "last_message": message,
            "updated_at": Date().timeIntervalSince1970.description
        ]
        userConversationsRef.setValue(data)
    }
    
    func recordVoiceMessage() {
        
    }
    
}
