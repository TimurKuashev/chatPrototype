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
    
    private var sortedIsFinished: Bool = false
    private var timer: Timer?
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
        if usersConversations.count <= dialogPosition {
            return (users[dialogPosition].username, "No dialogs", "Null date")
        }
        
        guard let myUid = FirebaseAuthService.getUserId() else { return (nil, nil, nil) }
        guard let conversationId = self.usersConversations[dialogPosition].conversationId else { return (nil, nil, nil) }
        guard let neededConversation = self.conversations[conversationId] else { return (nil, nil, nil) }
        guard let chatPartnerId = neededConversation.participant0 == myUid ? neededConversation.participant1 : neededConversation.participant0
            else {return (nil, nil, nil) }
        guard let userName = self.users.first(where: { $0.id == chatPartnerId })?.id else { return (nil, nil, nil) }
        
        return (userName, self.usersConversations[dialogPosition].lastMessage, usersConversations[dialogPosition].updatedAt)
    }
    
    func getUserId(byUsername username: String?) -> String? {
        return self.users.first(where: { $0.username == username })?.id
    }
    
}

// MARK: - Private Methods
private extension MainPageModel {
    
    
    func initialConfigure() {
        setupAndStartTimer()
        fetchUsers()
        fetchData()
    }
    
    func fetchData() {
        // Fetching the Users_Conversations data
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        Database.database().reference().child(FirebaseTableNames.usersConverstaions).child(myUid).observe(.value, with: {
            [weak self] (usersConverstaionsSnapshot: DataSnapshot) in
            guard let self = self else {
                return
            }
            if let userConversationData = usersConverstaionsSnapshot.value as? [String: AnyObject] {
                for key in userConversationData.keys {
                    guard let keyData = userConversationData[key] as? [String: AnyObject] else {
                        continue
                    }
                    self.usersConversations.append(UsersConversationsTable(dictionary: keyData))
                }
            }
            self.fetchConversations()
            self.sortedIsFinished = false
            DispatchQueue.global(qos: .background).sync {
                self.usersConversations = self.usersConversations.sorted(by: {
                    lhs, rhs -> Bool in
                    guard let firstDate = lhs.updatedAt, let secondDate = rhs.updatedAt else {
                        return true
                    }
                    return firstDate > secondDate
                })
                self.sortedIsFinished = true
            }
        })
    }
    
    func fetchConversations() {
        guard let myUid = FirebaseAuthService.getUserId() else { return }
        var conversationsLeft = self.usersConversations.count
        for userConversation in self.usersConversations {
            guard let conversationId = userConversation.conversationId else { continue }
            Database.database().reference().child(FirebaseTableNames.conversations).child(myUid).child(conversationId).observe(.value, with: {
                [weak self](conversationSnapshot: DataSnapshot) in
                guard let dictionary = conversationSnapshot.value as? [String: AnyObject], let self = self else {
                    return
                }
                self.conversations[conversationId] = ConversationsTable(dictionary: dictionary)
                conversationsLeft -= 1
            })
        }
    }
    
    func fetchUsers() {
        Database.database().reference().child(FirebaseTableNames.users).observe(.value, with: {
            [weak self](usersSnapshot: DataSnapshot) in
            guard let self = self, let dictionary = usersSnapshot.value as? [String: AnyObject] else {
                return
            }
            for key in dictionary.keys {
                guard let keyData = dictionary[key] as? [String: AnyObject] else {
                    continue
                }
                self.users.append(UsersTable(dictionary: keyData))
            }
            self.allUsersWereFetched()
        })
    }
    
    @objc func allUsersWereFetched() {
        if sortedIsFinished == true {
            delegate?.usersConversationsWereSorted()
        } else {
            setupAndStartTimer()
        }
    }
    
    func setupAndStartTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(allUsersWereFetched), userInfo: nil, repeats: false)
    }
    
}
