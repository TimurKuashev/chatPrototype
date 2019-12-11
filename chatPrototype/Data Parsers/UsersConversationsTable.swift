//
//  UsersConversationsTable.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 08.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

class UsersConversationsTable {
    var conversationId: String?
    var lastMessage: String?
    var updatedAt: String?
    init(dictionary: [String: AnyObject]) {
        self.conversationId = dictionary["conversation_id"] as? String
        self.lastMessage = dictionary["last_message"] as? String
        self.updatedAt = dictionary["updated_at"] as? String
    }
    
    func isEqualTo(userConversation: UsersConversationsTable) -> Bool {
        return (self.conversationId == userConversation.conversationId)
    }
}
