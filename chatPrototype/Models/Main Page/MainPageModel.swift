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
    func fetchingNewConversation()
    func fetchingNewUser()
}

final class MainPageModel {
    
    // MARK: - Private Properties
    private var users: [UsersTable] = []
    private var conversations: [ConverstaionsTable] = []
    
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
    
    func dataForDialog(dialogIndex: Int) -> UsersTable {
        return users[dialogIndex]
    }
    
}

// MARK: - Private Methods
private extension MainPageModel {
    
    func initialConfigure() {        
        setListeners()
    }
    
    func setListeners() {
        // Fetch all users
        Database.database().reference().child(FirebaseTableNames.users).observe(.childAdded, with: {
            [weak self] (snapshot: DataSnapshot) in
            guard let self = self else {
                return
            }
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.users.append(UsersTable(dictionary: dictionary) )
                self.delegate?.fetchingNewUser()
            }
        })
        // Fetch all converstaions
        Database.database().reference().child(FirebaseTableNames.conversations).observe(.childAdded, with: {
            [weak self](snapshot: DataSnapshot) in
            guard let self = self else {
                return
            }
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.conversations.append(ConverstaionsTable(dictionary: dictionary))
                self.delegate?.fetchingNewConversation()
            }
        })
    }
    
}
