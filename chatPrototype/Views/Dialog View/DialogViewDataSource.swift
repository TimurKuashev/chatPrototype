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
    func newTextMessagesComes()
    func newImageMessageComes(stringImageUrl: String?)
    func newDocumentMessageComes(stringDocumentUrl: String?)
    func newVoiceMessageComes()
}

final class DialogViewDataSource: NSObject {
    
    // MARK: - Properties
    private(set) var messages: [MessagesTable] = []
    var delegate: DialogViewDataSourceDelegate?
    var collectionView: UICollectionView?
    private(set) var chatPartnerId: String!
    private(set) var conversationId: String?
    
    // MARK: - Methods
    override init() {
        super.init()
    }
    
    func setChatPartnerId(id: String?) {
        guard let id = id else {
            return
        }
        self.chatPartnerId = id
        
        fetchNeededConversationId {
            [weak self] in
            guard let self = self else { return }
            self.setListenerToMessages(for: FirebaseAuthService.getUserId())
            self.setListenerToMessages(for: self.chatPartnerId)
        }
        
    }
    
}

// MARK: - Private Methods
private extension DialogViewDataSource {
    
    private func fetchNeededConversationId(successCompletion: @escaping () -> Void) {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        Database.database().reference().child(FirebaseTableNames.conversations).child(myUid).observeSingleEvent(of: .value) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
            for key in dictionary.keys {
                if let keyData = dictionary[key] as? [String: AnyObject] {
                    let conversation = ConversationsTable(dictionary: keyData)
                    if (conversation.participant0 == self.chatPartnerId || conversation.participant1 == self.chatPartnerId) {
                        self.conversationId = snapshot.key
                        successCompletion()
                        return
                    }
                }
            }
        }
    }
    
    func setListenerToMessages(for wrappedUid: String?) {
        guard let convId = self.conversationId, let uid = wrappedUid else {
            return
        }
        Database.database().reference().child(FirebaseTableNames.messages).child(uid).child(convId).observe(.value) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let newMessage = MessagesTable(dictionary: dictionary)
            self.messages.append(newMessage)
            switch self.messages.last!.type {
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
        default:
            return UICollectionViewCell()
        }
    }
    
}
