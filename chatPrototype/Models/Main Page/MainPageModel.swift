//
//  MainPageModel.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

protocol MainPageModelDelegate: AnyObject {
    func usersWereFetched()
    func updateDialogs()
}

final class MainPageModel {
    
    // MARK: - Private Properties
    private var users: [UsersTable] = []
    private var conversations: [String: ConversationsTable] = [:]
    private var usersConversations: [UsersConversationsTable] = []
    
    // MARK; - Public Properties
    weak var delegate: MainPageModelDelegate?
    
    // MARK: - Lifecycle
    init() {
        initialConfigure()
    }
    
}

// MARK: - Public Methods
extension MainPageModel {
    
    func getUsernames(by usersId: Array<String>) -> Array<String> {
        guard usersId.count > 0 else {
            return []
        }
        var result: Array<String> = []
        for userId in usersId {
            if let userName = self.users.first(where: { $0.id == userId } )?.username {
                result.append(userName)
            }
        }
        return result
    }
    
    func chatsCount() -> Int {
        return users.count
    }
    
    func dataForPreviewOfTheDialog(dialogPosition: Int) -> (participantName: String, lastMesageText: String?, lastMessageDate: String?) {
        var participantName: String = String()
        guard self.usersConversations.count > dialogPosition else {
            return (users[dialogPosition].username ?? participantName, nil, nil)
        }
        guard let myUsername = self.users.first(where: { $0.id == FirebaseAuthService.getUserId() } )?.username else {
            return (users[dialogPosition].username ?? participantName, nil, nil)
        }
        
        if let conv = self.conversations[self.usersConversations[dialogPosition].conversationId ?? "some doesn't existing key"] {
            for participantId in conv.participants {
                if let username = self.users.first(where: { $0.id == participantId })?.username {
                    guard username != myUsername else { continue }
                    participantName += username + " "
                }
            }
        }
        if participantName.isEmpty == true {
            participantName.append(myUsername)
        }
        return (participantName, self.usersConversations[dialogPosition].lastMessage, self.usersConversations[dialogPosition].updatedAt)
    }
    
    func getUsers() -> [UsersTable] {
        return self.users
    }
    
    func chatInfoBy(dialogPosition: Int) -> (userConvId: String?, conversationId: String?, participantsId: Array<String>) {
        guard dialogPosition < self.usersConversations.count else {
            guard let userId = self.users[dialogPosition].id else {
                return (nil, nil, [])
            }
            return (nil, nil, [userId])
        }
        
        let userConvId = self.usersConversations[dialogPosition].conversationId
        
        if let convId = self.usersConversations[dialogPosition].conversationId {
            if var ids = self.conversations[convId]?.participants {
                ids.removeAll(where: { $0 == FirebaseAuthService.getUserId() } )
                return (userConvId, convId, ids)
            }
        }
        return (userConvId, nil, [self.users[dialogPosition].id ?? "Error"] )
    }
    
    func searchMessagesBy(phrase: String, completion: @escaping (_ messages: [MessagesTable]) -> Void) {
        var convIdCounter: Int = 0
        for userConv in self.usersConversations {
            if let convId = userConv.conversationId {
                convIdCounter += 1
                Database.database().reference().child(FirebaseTableNames.messages).child(convId).queryOrdered(byChild: "text").queryStarting(atValue: phrase).queryEnding(atValue: phrase + "\u{f8ff}").observeSingleEvent(of: .value) {
                    (snapshot: DataSnapshot) in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                    var messages: [MessagesTable] = []
                    for key in dictionary.keys {
                        if let keyData = dictionary[key] as? [String: AnyObject] {
                            messages.append(MessagesTable(dictionary: keyData))
                        }
                    }
                    completion(messages)
                }
            }
        }
    }
    
}

// MARK: - Private Methods
private extension MainPageModel {
    
    func initialConfigure() {
        fetchUsers()
    }
    
    func isUserConversationExist(userConv: UsersConversationsTable) -> Int? {
        for i in 0..<usersConversations.count {
            if usersConversations[i].isEqualTo(userConversation: userConv) {
                return i
            }
        }
        return nil
    }
    
    // MARK: - Fetch Data
    func fetchUsers() {
        Database.database().reference().child(FirebaseTableNames.users).observe(.value) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
            for key in dictionary.keys {
                if let keyData = dictionary[key] as? [String: AnyObject] {
                    self.users.append(UsersTable(dictionary: keyData) )
                }
            }
            self.delegate?.usersWereFetched()
            self.delegate?.updateDialogs()
            self.fetchUsersConversations()
        }
    }
    
    func fetchUsersConversations() {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).observe(.childAdded) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String: AnyObject], let convId = dictionary["conversation_id"] as? String else {
                self.delegate?.updateDialogs()
                return
            }
            self.usersConversations.append(UsersConversationsTable(dictionary: dictionary))
            self.fetchConversation(for: convId)
        }
        
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).observe(.childChanged) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                self.delegate?.updateDialogs()
                return
            }
            let userConversation = UsersConversationsTable(dictionary: dictionary)
            guard let index = self.usersConversations.firstIndex(where: { $0.conversationId == userConversation.conversationId } ) else { return }
            self.usersConversations[index] = userConversation
            self.delegate?.updateDialogs()
        }

    }
    
    func fetchConversation(for userConvId: String) {
        Database.database().reference().child(FirebaseTableNames.conversations).child(userConvId).observeSingleEvent(of: .value) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
            self.conversations[userConvId] = ConversationsTable(dictionary: dictionary)
            self.sortUsersConversations()
            self.delegate?.updateDialogs()
        }
    }
    
    // MARK: - Sort Data
    func sortUsersConversations() {
        usersConversations = usersConversations.sorted(by: {
            lhs, rhs -> Bool in
            guard let firstDate = lhs.updatedAt, let secondDate = rhs.updatedAt else {
                return true
            }
            return firstDate > secondDate
        })
    }
}

