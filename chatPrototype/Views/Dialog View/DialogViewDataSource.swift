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
    func updateChat()
    func newTextMessagesComes()
    func newImageMessageComes(stringImageUrl: String?)
    func newDocumentMessageComes(stringDocumentUrl: String?)
    func newVoiceMessageComes()
}

final class DialogViewDataSource: NSObject {
    
    // MARK: - Properties
    private(set) var messages: [MessagesTable] = []
    var delegate: DialogViewDataSourceDelegate?
    
    // MARK: - Methods
    override init() {
        super.init()
    }
    
    func loadDataWith(conversationId: String?) {
        guard let convId = conversationId else { return }
        
        Database.database().reference().child(FirebaseTableNames.messages).child(convId).observe(.childAdded) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, var dictionary = snapshot.value as? [String: AnyObject] else { return }
            dictionary["keyInDatabase"] = snapshot.key as AnyObject
            let newMessage = MessagesTable(dictionary: dictionary)
            self.messages.append(newMessage)
            switch newMessage.type {
            case .text:
                self.delegate?.newTextMessagesComes()
            case .image:
                self.delegate?.newImageMessageComes(stringImageUrl: newMessage.imageURL)
            case .document:
                self.delegate?.newDocumentMessageComes(stringDocumentUrl: newMessage.imageURL)
            default:
                break
            }
        }
        
        Database.database().reference().child(FirebaseTableNames.messages).child(convId).observe(.childChanged) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, var dictionary = snapshot.value as? [String: AnyObject] else { return }
            dictionary["keyInDatabase"] = snapshot.key as AnyObject
            var changedMessage = MessagesTable(dictionary: dictionary)
            self.update(message: &changedMessage)
            self.sortMessages()
            self.delegate?.updateChat()
        }
        
        Database.database().reference().child(FirebaseTableNames.messages).child(convId).observe(.childRemoved) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else { return }
            guard let indexOfRemovedMessage = self.messages.firstIndex(where: { $0.keyInDatabase == snapshot.key } ) else { return }
            self.messages.remove(at: indexOfRemovedMessage)
            self.sortMessages()
            self.delegate?.updateChat()
        }
    }
    
    private func update(message: inout MessagesTable) {
        for i in 0..<self.messages.count {
            if self.messages[i].keyInDatabase == message.keyInDatabase {
                self.messages[i] = message
                return
            }
        }
    }
    
    private func sortMessages() {
        self.messages = self.messages.sorted(by: {
            lhs, rhs -> Bool in
            guard let firstDate = lhs.createdAt, let secondDate = rhs.createdAt else {
                return true
            }
            return firstDate < secondDate
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
            if let image = CacheManager.shared.savedImages[messages[indexPath.section].imageURL ?? "qwertyqwerty"] {
                cell.set(image: image)
            } else {
                cell.set(image: UIImage(named: "empty_image"))
            }
            return cell
        case .location:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.textMessageCell, for: indexPath) as? TextMessageCell else {
                return UICollectionViewCell()
            }
            cell.set(text: self.messages[indexPath.section].text, senderID: self.messages[indexPath.section].sender)
            return cell
        case .document:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.documentMessageCell, for: indexPath) as? DocumentMessageCell else {
                return UICollectionViewCell()
            }
            cell.set(documentName: "DASD", senderId: self.messages[indexPath.section].sender)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
}
