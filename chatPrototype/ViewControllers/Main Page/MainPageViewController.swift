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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

// MARK: - Private Methods
private extension MainPageViewController {
    
    private func initialConfigure() {
        model.delegate = self
        
        let navController = UINavigationController(rootViewController: self)
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = navController
        
        self.view.backgroundColor = UIColor(68, 73, 87)
        lblUsername.textColor = .white
        lblUsername.text = UserDefaults.standard.value(forKey: CustomPropertiesForUserDefaults.username) as? String
        lblChatsTitle.textColor = .yellow
        if let newDescriptor = UIFont.systemFont(ofSize: 16).fontDescriptor.withSymbolicTraits(.traitBold) {
            lblChatsTitle.font = UIFont(descriptor: newDescriptor, size: 16)
        }
        
        btnCreateGroupChat.setTitle(nil, for: .normal)
        btnCreateGroupChat.setImage(UIImage(named: "icon_plus"), for: .normal)
        btnCreateGroupChat.tintColor = .white
        btnCreateGroupChat.addTarget(self, action: #selector(onCreateGroupChatTapped(_:)), for: .touchUpInside)
        
        setupDialogPreviewList()
    }
    
    private func setupDialogPreviewList() {
        dialogsList.register(UINib(nibName: CellIdentifiers.dialogPreviewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.dialogPreviewCell)
        (dialogsList.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
        dialogsList.dataSource = self
        dialogsList.delegate = self
        dialogsList.backgroundColor = .clear
    }
    
    @objc private func onCreateGroupChatTapped(_ sender: UIButton?) {
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
            return UICollectionViewCell()
        }
        let data = model.dataForPreviewOfTheDialog(dialogPosition: indexPath.section)
        cell.setup(chatPartnerName: data.username!, lastMessage: data.lastMesageText ?? "", lastMessageDate: data.lastMessageDate!)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension MainPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let username = (collectionView.cellForItem(at: indexPath) as? DialogPreviewCell)?.getDisplayedData().username else {
            self.presentAlert(title: "Error", message: "Sorry, something went wrong. Please, try again later", actions: [], displayCloseButton: true)
            return
        }
        guard let chatPartnerId = self.model.getUserId(byUsername: username) else {
            self.presentAlert(title: "Error", message: "Sorry, something went wrong. Please, try again later", actions: [], displayCloseButton: true)
            return
        }
        let chatVC = ChatPageViewController(nibName: XibNameHelpers.chatPage, bundle: nil)
        chatVC.chatPartnerId = chatPartnerId
        chatVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(chatVC, animated: true)
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
    
    func usersConversationsWereSorted() {
        dialogsList.reloadData()
    }
    
}
