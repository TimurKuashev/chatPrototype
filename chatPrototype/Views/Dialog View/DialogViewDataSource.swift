//
//  DialogViewDataSource.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation
import Firebase

protocol DialogViewDataSourceDelegate {
    func newMessagesComes()
    func update()
}

final class DialogViewDataSource: NSObject {
    
    // MARK: - Properties
    private(set) var messages: [MessagesTable] = []
    var delegate: DialogViewDataSourceDelegate?
    var collectionView: UICollectionView?
    private(set) var chatPartnerId: String?
    
    // MARK: - Methods
    override init() {
        super.init()
        
//        Database.database().reference().child(FirebaseTableNames.messages).observe(.childAdded, with: {
//            [weak self] (snapshot: DataSnapshot) in
//            guard let self = self else {
//                return
//            }
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.messages.append(MessagesTable(dictionary: dictionary))
//                self.delegate?.newMessagesComes()
//            }
//        })
    }
    
    func setChatPartnerId(id: String?) {
        guard let id = id else {
            return
        }
        self.chatPartnerId = id
        setListenerToMessages()
    }
    
}

// MARK: - Private Methods
private extension DialogViewDataSource {
    
    func initialConfigure() {
        
    }
    
    func setListenerToMessages() {
        guard let myUid = FirebaseAuthService.getUserId() else {
            return
        }
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).observe(.value, with: {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else {
                return
            }
//            print("snaphot: \(snapshot)")
            let converstainsId = snapshot.key
            Database.database().reference().child(FirebaseTableNames.messages).child(converstainsId).observe(.childAdded, with: {
                [weak self] (messageSnapshot: DataSnapshot) in
                guard let self = self else {
                    return
                }
//                print("snaphot: \(messageSnapshot)")
                if let messageDictionary = messageSnapshot.value as? [String: AnyObject] {
                    let message = MessagesTable(dictionary: messageDictionary)
                    self.messages.append(message)
                    self.delegate?.newMessagesComes()
                }
            })
        })
        
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(chatPartnerId!).observe(.value, with: {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else {
                return
            }
//            print("snaphot: \(snapshot)")
            let converstainsId = snapshot.key
            Database.database().reference().child(FirebaseTableNames.messages).child(converstainsId).observe(.childAdded, with: {
                [weak self] (messageSnapshot: DataSnapshot) in
                guard let self = self else {
                    return
                }
//                print("snaphot: \(messageSnapshot)")
                if let messageDictionary = messageSnapshot.value as? [String: AnyObject] {
                    let message = MessagesTable(dictionary: messageDictionary)
                    self.messages.append(message)
                    self.delegate?.newMessagesComes()
                }
            })
        })
        
    }
    
}

// MARK: - UICOllectionViewDataSource
extension DialogViewDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.messages[indexPath.section].type {
        case .text:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.textMessageCell, for: indexPath) as? TextMessageCell else {
                return UICollectionViewCell()
            }
            cell.set(text: self.messages[indexPath.section].text, senderID: self.messages[indexPath.section].sender)
            return cell
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.imageMessageCell, for: indexPath) as? ImageMessageCell else {
                return UICollectionViewCell()
            }

//            cell.set(image: self.messages[indexPath.section].imageURL)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
}
