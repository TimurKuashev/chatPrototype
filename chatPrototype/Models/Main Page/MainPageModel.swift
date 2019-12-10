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
    func usersConversationsWereSorted()
}

final class MainPageModel {
    
    // MARK: - Private Properties
    private var users: [UsersTable] = []
    private var conversations: [String: ConversationsTable] = [:]
    private var usersConversations: [UsersConversationsTable] = []
    
    // MARK; - Public Properties
    var delegate: MainPageModelDelegate?
    
    // MARK: - Lifecycle
    init() {
        initialConfigure()
    }
    
}

// MARK: - Public Methods
extension MainPageModel {
    
    func chatsCount() -> Int {
        return users.count
    }
    
    func dataForPreviewOfTheDialog(dialogPosition: Int) -> (username: String?, lastMesageText: String?, lastMessageDate: String?) {
        guard self.usersConversations.count > dialogPosition else { return (users[dialogPosition].username, nil, nil) }
        return (users[dialogPosition].username, self.usersConversations[dialogPosition].lastMessage, self.usersConversations[dialogPosition].updatedAt)
    }
    
    func getUserId(byUsername username: String?) -> String? {
        return self.users.first(where: { $0.username == username })?.id
    }
    
}

// MARK: - Private Methods
private extension MainPageModel {
    
    func initialConfigure() {
        fetchUsers()
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
            self.fetchUsersConversations()
        }
    }
    
    func fetchUsersConversations() {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).observeSingleEvent(of: .value) {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                self.delegate?.usersConversationsWereSorted()
                return
            }
            for key in dictionary.keys {
                if let keyData = dictionary[key] as? [String: AnyObject] {
                    self.usersConversations.append(UsersConversationsTable(dictionary: keyData))
                }
            }
            self.fetchConversations()
        }
    }
    
    func fetchConversations() {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        var conversationsLeft = usersConversations.count
        for usConv in usersConversations {
            guard let convId = usConv.conversationId else { continue }
            Database.database().reference().child(FirebaseTableNames.conversations).child(myUid).child(convId).observeSingleEvent(of: .value) {
                [weak self] (snapshot: DataSnapshot) in
                guard let self = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
                conversationsLeft -= 1
                self.conversations[convId] = ConversationsTable(dictionary: dictionary)
                if conversationsLeft == 0 {
                    self.sortUsersConversations()
                    self.delegate?.usersConversationsWereSorted()
                }
            }
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
        sortUsersByUsersConversations()
    }
    
    func sortUsersByUsersConversations() {
        guard let myUid = FirebaseAuthService.getUserId(), conversations.count > 0 else { return }
        var usersIdArray: [String?] = []
        for userConv in self.usersConversations {
            if let convId = userConv.conversationId, let conv = self.conversations[convId] {
                usersIdArray.append(conv.participant0 == myUid ? conv.participant1 : conv.participant0)
            }
        }
        
        var i: Int = 0
        var j: Int = 0
        while (i < users.count) {
            while (j < usersIdArray.count) {
                if (users[i].id == usersIdArray[j]) {
                    let tempname = users[j]
                    users[j] = users[i]
                    users[i] = tempname
                }
                j += 1
            }
            j = 0
            i += 1
        }
        
    }
}

