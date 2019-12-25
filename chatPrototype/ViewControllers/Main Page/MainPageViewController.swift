//
//  MainPageViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase


final class MainPageViewController: UIViewController {
    
    // MARK: - @IBOutlets & Private Properties
    @IBOutlet private var lblUsername: UILabel!
    @IBOutlet private var btnCreateGroupChat: UIButton!
    @IBOutlet private var lblChatsTitle: UILabel!
    @IBOutlet private var dialogsList: UICollectionView!
    @IBOutlet private var btnSearch: UIButton!
    @IBOutlet private var tfSearch: UITextField!
    
    private var model: MainPageModel = MainPageModel()
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        dialogsList.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

// MARK: - Private Methods
private extension MainPageViewController {
    
    private func initialConfigure() {
        HudManager.push(to: self.view)
        model.delegate = self
        
        btnSearch.addTarget(self, action: #selector(btnSearchTapped(_:)), for: .touchUpInside)
        let navController = UINavigationController(rootViewController: self)
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = navController
        
        self.view.backgroundColor = UIColor(68, 73, 87)
        lblUsername.textColor = .white
        lblChatsTitle.textColor = .yellow
        if let newDescriptor = UIFont.systemFont(ofSize: 16).fontDescriptor.withSymbolicTraits(.traitBold) {
            lblChatsTitle.font = UIFont(descriptor: newDescriptor, size: 16)
        }
        
        btnCreateGroupChat.setTitle(nil, for: .normal)
        btnCreateGroupChat.setImage(UIImage(named: "icon_plus"), for: .normal)
        btnCreateGroupChat.tintColor = .white
        btnCreateGroupChat.addTarget(self, action: #selector(onCreateGroupChatTapped(_:)), for: .touchUpInside)
        
        setupDialogPreviewList()
        guard let username = UserDefaults.standard.value(forKey: CustomPropertiesForUserDefaults.username) as? String else {
            return
        }
        lblUsername.text = username
        guard let id = FirebaseAuthService.getUserId() else { return }
        let data: Dictionary<String, String> = [
            "id": id,
            "status": "online",
            "username": username
        ]
        Database.database().reference().child(FirebaseTableNames.users).child(id).setValue(data)
    }
    
    private func setupDialogPreviewList() {
        dialogsList.register(UINib(nibName: CellIdentifiers.dialogPreviewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.dialogPreviewCell)
        (dialogsList.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
        dialogsList.dataSource = self
        dialogsList.delegate = self
        dialogsList.backgroundColor = .clear
    }
    
    @objc private func onCreateGroupChatTapped(_ sender: UIButton?) {
        let vc = UsersListViewController()
        vc.set(users: self.model.getUsers() )
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func btnSearchTapped(_ sender: UIButton?) {
        guard let searchPhrase = tfSearch.text else { return }
        model.searchMessagesBy(phrase: searchPhrase) {
            [weak self] (messages: [MessagesTable]) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let vc = FindedMessagesViewController()
                vc.messages = messages
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension MainPageViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.model.chatsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.dialogPreviewCell, for: indexPath) as? DialogPreviewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.dialogPreviewCell, for: indexPath)
        }
        let data = model.dataForPreviewOfTheDialog(dialogPosition: indexPath.section)
        cell.setup(chatPartnerName: data.participantName, lastMessage: data.lastMesageText ?? "No messages", lastMessageDate: data.lastMessageDate ?? "Null Date")
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension MainPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Data for chat from model
        let chatInfo = self.model.chatInfoBy(dialogPosition: indexPath.section)
        guard chatInfo.participantsId.count > 0 else {
            return
        }
        let chatVC = ChatPageViewController(nibName: XibNameHelpers.chatPage, bundle: nil)
        chatVC.participantsNames = self.model.getUsernames(by: chatInfo.participantsId)
        chatVC.chatInfo = (chatInfo.userConvId, chatInfo.conversationId, chatInfo.participantsId)
        chatVC.delegate = self
        chatVC.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(chatVC, animated: true)
        let temp = LocationViewController()
        self.navigationController?.pushViewController(temp, animated: true)
//        self.present(temp, animated: true)
    }
}

// MARK: - ChatPageDelegate
extension MainPageViewController: ChatPageDelegate {
    func chatStateChanged(chatId: String?, lastMessage: MessagesTable?) {
        guard let userConvId = chatId, let myUid = FirebaseAuthService.getUserId() else {
            return
        }
        guard let messageText = lastMessage?.text, let messageDate = lastMessage?.createdAt else {
            Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).child(userConvId).removeValue()
            return
        }
        
        let newData: Dictionary<String, Any> = [
            "conversation_id": userConvId,
            "last_message": messageText,
            "updated_at": messageDate
        ]
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).child(userConvId).updateChildValues(newData)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainPageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 30, height: 80)
    }
    
}

// MARK: - MainPageModelDelegate
extension MainPageViewController: MainPageModelDelegate {
    
    func usersWereFetched() {
        self.lblUsername.text = self.model.getUsernames(by: [FirebaseAuthService.getUserId() ?? "Error"]).first
    }
    
    func updateDialogs() {
        HudManager.pop(from: self.view)
        dialogsList.reloadData()
    }
    
}

// MARK: - UsersListDelegate
extension MainPageViewController: UsersListDelegate {
    func createChatPressed(with selectedUsersId: [String]) {
        // Pop UsersListViewController
        self.navigationController?.popViewController(animated: true)
        // Creating the chat
        let chatVC = ChatPageViewController()
        chatVC.modalPresentationStyle = .fullScreen
        chatVC.delegate = self
        chatVC.chatInfo = (nil, nil, selectedUsersId)
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
}
