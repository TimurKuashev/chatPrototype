//
//  ChatPageViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MobileCoreServices

final class ChatPageViewController: UIViewController {
    
    // MARK: - @IBOutlet  Private Properties
    @IBOutlet private var lblConversationName: UILabel!
    @IBOutlet private var btnOptions: UIButton!
    @IBOutlet private var dialogView: DialogView!
    @IBOutlet private var dialogBottomPanel: DialogBottomPanelView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    private lazy var imageAndCameraPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        return picker
    }()
    
    private lazy var documentPicker: UIDocumentPickerViewController = {
        let picker = UIDocumentPickerViewController(documentTypes: [
            String(kUTTypeText),
            String(kUTTypeContent),
            String(kUTTypeItem),
            String(kUTTypeData)
        ], in: .import)
        picker.delegate = self
        return picker
    }()
    
    var chatPartnerId: String!
    
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
    
    func updateConversationsTables(withChildKey: String) {
        
    }
    
}

// MARK: - DialogBottomPanelViewDelegate
extension ChatPageViewController: DialogBottomPanelViewDelegate {
    
    func requestRecordVoiceMessage() {
    }
    
    func requestSendFile() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let attachImageAction = UIAlertAction(title: "Photo From Library", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { alertController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.selectImage()
        })
        
        let createPhotoAction = UIAlertAction(title: "Camera", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { alertController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.openCameraAndTakePhoto()
        })
        
        let attachFileAction = UIAlertAction(title: "File", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { alertController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.selectFile()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(attachImageAction)
        alertController.addAction(attachFileAction)
        alertController.addAction(createPhotoAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func requestSend(message: String?) {
        guard let myUid = FirebaseAuthService.getUserId() else {
            return
        }
        // Send Data To Messages Table
        let data: Dictionary<String, Any> = [
            "createdAt": NSDate().timeIntervalSince1970.description,
            "sender": myUid,
            "text": message ?? "",
            "type": "text"
        ]
        send(message: data)
    }
    
    
    private func send(message: [String: Any]) {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        // Send Data To Conversations Table
        let conversationsRef = Database.database().reference().child(FirebaseTableNames.conversations).child(myUid).child(chatPartnerId!)
        var data: Dictionary<String, Any> = ["createdAt": Date().timeIntervalSince1970.description]
        let tempData = [
            "0": FirebaseAuthService.getUserId(),
            "1": self.chatPartnerId!
        ]
        data["participants"] = tempData
        conversationsRef.setValue(data)
        let chatPartnerConversationRef = Database.database().reference().child(FirebaseTableNames.conversations).child(chatPartnerId).child(myUid)
        chatPartnerConversationRef.setValue(data)
        
        // Send Data To Users_Conversations Table
        data.removeAll()
        data = [
            "conversation_id": conversationsRef.key!,
            "last_message": message["text"] ?? "",
            "updated_at": Date().timeIntervalSince1970.description
        ]
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).child(conversationsRef.key!).setValue(data)
        data["conversation_id"] = chatPartnerConversationRef.key!
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(chatPartnerId).child(chatPartnerConversationRef.key!).setValue(data)
        
        // Send Data to Messages Table
        Database.database().reference().child(FirebaseTableNames.messages).child(myUid).child(conversationsRef.key!).setValue(message)
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ChatPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.global(qos: .background).async {
                let imageName = UUID().uuidString
                let ref = Storage.storage().reference().child(FirebaseTableNames.imageMessages).child(imageName)
                
                if let uploadData = pickedImage.jpegData(compressionQuality: 0.2) {
                    ref.putData(uploadData, metadata: nil, completion: {
                        [weak self](metadata, error) in
                        guard let self = self else { return }
                        guard error == nil else {
                            self.presentAlert(title: "", message: "Something went wrong. Please, try again later", actions: [], displayCloseButton: true)
                            return
                        }
                        var messageData: Dictionary<String, Any> = [
                            "createdAt": Date().timeIntervalSince1970.description,
                            "sender": FirebaseAuthService.getUserId() ?? "Error",
                            "text": "Image",
                            "type": "image"
                        ]
                        ref.downloadURL(completion: {
                            [weak self](url, error) in
                            guard let self = self else { return }
                            guard error == nil, let unwrappedUrl = url else {
                                self.presentAlert(title: "Error", message: "Sorry, something went wrong", actions: [], displayCloseButton: true)
                                return
                            }
                            messageData["image_url"] = String(describing: unwrappedUrl)
                            self.send(message: messageData)
                        })
                    })
                }
            }
        }
    }
    
}

// MARK: - UIDocumentPickerDelegate
extension ChatPageViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
    }
}

// MARK: - Select & Attach File Methods
private extension ChatPageViewController {
    
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imageAndCameraPicker.sourceType = .savedPhotosAlbum
            imageAndCameraPicker.allowsEditing = false
            self.present(imageAndCameraPicker, animated: true)
        } else {
            self.presentAlert(title: "Error", message: "Allow the application to access the gallery in the phone settings", actions: [], displayCloseButton: true)
        }
    }
    
    func selectFile() {
        self.present(documentPicker, animated: true)
    }
    
    func openCameraAndTakePhoto() {
        imageAndCameraPicker.sourceType = .camera
        imageAndCameraPicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.present(imageAndCameraPicker, animated: true)
        } else {
            self.presentAlert(title: "Error", message: "Allow the application to access the camera in the phone settings", actions: [], displayCloseButton: true)
        }
    }
    
}
