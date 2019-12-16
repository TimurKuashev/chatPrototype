//
//  ChatPageViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import CoreLocation
import FirebaseStorage
import MobileCoreServices

protocol ChatPageDelegate: AnyObject {
    func chatStateChanged(chatId: String?, lastMessage: MessagesTable?)
}

final class ChatPageViewController: UIViewController {
    
    // MARK: - @IBOutlet & Private Properties
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
    
    private lazy var locationManager: LocationManager = {
        let locManager = LocationManager()
        locManager.delegate = self
        return locManager
    }()
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    
    // MARK: - Public Properties
    var chatInfo: (usersConversationId: String?, conversationId: String?, chatPartnerId: String?) = (nil, nil, nil)
    var chatPartnerName: String?
    var delegate: ChatPageDelegate?
    
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
        if self.recordingSession == nil {
            self.recordingSession = AVAudioSession.sharedInstance()
        }
        do {
            try recordingSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: AVAudioSession.Mode.spokenAudio)
            try recordingSession.setActive(true)
            try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            return
        }
        
        lblConversationName.text = self.chatPartnerName
        dialogView.delegate = self
        dialogBottomPanel.delegate = self
        
        self.navigationItem.title = ""
        btnOptions.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        btnOptions.setTitle("Media", for: .normal)
        
        // Keyboard show/hide events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if (chatInfo.conversationId != nil) {
            dialogView.setConversation(id: chatInfo.conversationId)
        }
    }
    
    @objc private func openSettings(_ sender: UIButton?) {
        let vc = SharedImagesViewController()
        var imagesUrls: [String?] = []
        dialogView.getImagesUrls(writeSpace: &imagesUrls)
        vc.imagesUrls = imagesUrls
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    private func getConversationId() -> String? {
        if let convId = self.chatInfo.conversationId {
            return convId
        } else {
            return Database.database().reference().child(FirebaseTableNames.conversations).childByAutoId().key
        }
    }
    
}

// MARK: - DialogViewDelegate
extension ChatPageViewController: DialogViewDelegate {
    
    func onImageClicked(message: MessagesTable) {
        guard let imageUrl = message.imageURL, let image = CacheManager.shared.savedImages[imageUrl] else {
            return
        }
        let vc = ImageViewerViewController()
        vc.set(image: image)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTextClicked(message: MessagesTable) {
        guard let conversationId = self.chatInfo.conversationId, let messageId = message.keyInDatabase else {
            return
        }
        Database.database().reference().child(FirebaseTableNames.messages).child(conversationId).child(messageId).removeValue()
    }
    
    func dialogStateChanged(lastMesage: MessagesTable?) {
        self.delegate?.chatStateChanged(chatId: self.chatInfo.usersConversationId, lastMessage: lastMesage)
    }
    
}

// MARK: - DialogBottomPanelViewDelegate
extension ChatPageViewController: DialogBottomPanelViewDelegate {
    
    func showAttachmentMenu() {
        let attachmentMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let createPhotoAction = UIAlertAction(title: "Camera", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { attachmentMenuController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.openCameraAndTakePhoto()
        })
        
        let attachImageAction = UIAlertAction(title: "Photo From Library", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { attachmentMenuController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.selectImage()
        })
        
        let attachFileAction = UIAlertAction(title: "File", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { attachmentMenuController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.selectFile()
        })
        
        let sendCurrentLocationAction = UIAlertAction(title: "Current Location", style: .default, handler: {
            [weak self](action: UIAlertAction) in
            defer { attachmentMenuController.dismiss(animated: true, completion: nil) }
            guard let self = self else { return }
            self.shareCurrentLocation()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in
            attachmentMenuController.dismiss(animated: true, completion: nil)
        })
        
        attachmentMenuController.addAction(createPhotoAction)
        attachmentMenuController.addAction(attachImageAction)
        attachmentMenuController.addAction(attachFileAction)
        attachmentMenuController.addAction(sendCurrentLocationAction)
        attachmentMenuController.addAction(cancelAction)
        
        self.present(attachmentMenuController, animated: true)
    }
    
    func requestStartRecordVoiceMessage() {
        if self.recordingSession == nil {
            self.recordingSession = AVAudioSession.sharedInstance()
        }
        do {
            try recordingSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: AVAudioSession.Mode.spokenAudio)
            try recordingSession.setActive(true)
            try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            return
        }
        
        recordingSession.requestRecordPermission() {_ in}
        let audioFilename = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]).appendingPathComponent("recording.mp4")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ] as [String: Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Ну, не получилось что-то с записью")
        }
    }
    
    func requestCompleteRecordVoiceMessage() {
        self.audioRecorder.stop()
        audioRecorder = nil
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.mp4")
        do {
            let voiceMessageRowData = try Data(contentsOf: fileUrl)
            let voiceMessageName = UUID().uuidString
            let ref = Storage.storage().reference().child(FirebaseTableNames.voiceMessages).child(voiceMessageName)
            ref.putData(voiceMessageRowData, metadata: nil) {
                [weak self] (metadata, error) in
                guard let self = self else { return }
                guard error == nil else {
                    self.presentAlert(title: "Error", message: error?.localizedDescription, actions: [], displayCloseButton: true)
                    return
                }
                var messagesData: Dictionary<String, Any> = [
                    "createdAt": Date().timeIntervalSince1970,
                    "sender": FirebaseAuthService.getUserId() ?? "Error",
                    "text": "Voice message",
                    "type": "voice"
                ]
                ref.downloadURL(completion: {
                    [weak self] (url, error) in
                    guard let self = self else { return }
                    guard error == nil, let unwrappedUrl = url else {
                        self.presentAlert(title: "Error", message: error?.localizedDescription, actions: [], displayCloseButton: true)
                        return
                    }
                    messagesData["image_url"] = String(describing: unwrappedUrl)
                    self.send(message: messagesData)
                })
            }
        } catch {
            print("Не задалось")
        }
    }
    
    func requestSend(message: String?) {
        guard let myUid = FirebaseAuthService.getUserId(), let unwrappedMessage = message else {
            return
        }
        // Prepare Data For Sending
        let data: Dictionary<String, Any> = [
            "sender": myUid,
            "createdAt": Date().timeIntervalSince1970.description,
            "text": unwrappedMessage,
            "type": "text"
        ]
        send(message: data)
    }
    
    private func send(message: [String: Any]) {
        guard let myUid = FirebaseAuthService.getUserId() else {
            presentAlert(title: "Error", message: "It's look like you are not logged in. Please, reload your app", actions: [], displayCloseButton: true)
            return
        }
        guard let convId = self.getConversationId() else {
            self.presentAlert(title: "Error", message: "Sorry, but we can't find the conversations id. Restart your dialog", actions: [], displayCloseButton: true)
            return
        }
        guard let chatPartnerId = self.chatInfo.chatPartnerId else {
            self.presentAlert(title: "Error", message: "Sorry, but we the find your chat partner id. Please, restart this dialgo", actions: [], displayCloseButton: true)
            return
        }
        
        // Send Data To Conversations Table
        let convRef = Database.database().reference().child(FirebaseTableNames.conversations).child(convId)
        var data: Dictionary<String, Any> = ["createdAt": Date().timeIntervalSince1970.description]
        let participants = [
            "0": myUid,
            "1": chatPartnerId
        ]
        data["participants"] = participants
        convRef.setValue(data)
        
        // Send Data To Users_Conversations Table
        data.removeAll()
        data = [
            "conversation_id": convId,
            "last_message": message["text"] ?? "",
            "updated_at": Date().timeIntervalSince1970.description
        ]
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).child(convId).setValue(data)
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(chatPartnerId).child(convId).setValue(data)
        
        // Send Data to Messages Table
        Database.database().reference().child(FirebaseTableNames.messages).child(convId).childByAutoId().setValue(message)
        
        if self.chatInfo.conversationId == nil {
            self.chatInfo.conversationId = convId
        }
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
        guard urls.count > 0 else { return }
        let stringUrl = urls[0].path
        if FileManager.default.fileExists(atPath: stringUrl) {
            do {
                let uploadData = try Data(contentsOf: urls[0])
                let documentName = UUID().uuidString
                let ref = Storage.storage().reference().child(FirebaseTableNames.documentMessages).child(documentName)
                ref.putData(uploadData, metadata: nil, completion: {
                    [weak self] (metadata, error) in
                    guard let self = self else { return }
                    guard error == nil else {
                        self.presentAlert(title: "Error", message: error!.localizedDescription, actions: [], displayCloseButton: true)
                        return
                    }
                    var messageData: Dictionary<String, Any> = [
                        "createdAt": Date().timeIntervalSince1970.description,
                        "sender": FirebaseAuthService.getUserId() ?? "Error",
                        "text": "Document",
                        "type": "document"
                    ]
                    ref.downloadURL(completion: {
                        [weak self] (url, error) in
                        guard let self = self else { return }
                        guard error == nil, let unwrappedUrl = url else {
                            self.presentAlert(title: "Error", message: "Ref.DownloadUrl some error occured", actions: [], displayCloseButton: true)
                            return
                        }
                        messageData["image_url"] = String(describing: unwrappedUrl)
                        self.send(message: messageData)
                    })
                })
            } catch {
                self.presentAlert(title: "Error", message: "Sorry, but we can't get this document. Some error occured", actions: [], displayCloseButton: true)
            }
        }
    }
    
}

// MARK: - Select & Attach Methods
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
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imageAndCameraPicker.sourceType = .camera
            imageAndCameraPicker.allowsEditing = true
            self.present(imageAndCameraPicker, animated: true)
        } else {
            self.presentAlert(title: "Error", message: "Allow the application to access the camera in the phone settings", actions: [], displayCloseButton: true)
        }
    }
    
    func shareCurrentLocation() {
        self.locationManager.requestLocation()
    }
    
}

// MARK: - LocationManagerDelegate
extension ChatPageViewController: LocationManagerDelegate {
    
    func currentLocationFetchingSuccess(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude) ) {
            [weak self] (placemarks, error) in
            
            guard let self = self else { return }
            guard let placemark = placemarks?.first else {
                self.presentAlert(title: "Error", message: "Can not get you'r location.", actions: [], displayCloseButton: true)
                return
            }
            
            var messageData: Dictionary<String, Any> = [
                "createdAt": Date().timeIntervalSince1970.description,
                "sender": FirebaseAuthService.getUserId() ?? "Error",
                "type": "location"
            ]
            
            if let cityName = placemark.subAdministrativeArea, let streetName = placemark.thoroughfare {
                messageData["text"] = cityName + streetName
            } else {
                messageData["text"] = "lat: " + location.latitude.description + " lng: " + location.longitude.description
            }
            self.send(message: messageData)
        }
        
    }
    
    func currentLocationFetchingFail(error: Error?) {
        if let errorMessage = error?.localizedDescription {
            self.presentAlert(title: "Error", message: errorMessage + ". Please, try again later", actions: [], displayCloseButton: true)
        }
    }
    
}
