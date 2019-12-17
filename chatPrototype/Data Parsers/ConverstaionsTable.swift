//
//  ConversationsTable.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

class ConversationsTable: NSObject {
    var createdAt: String?
    var participants: Array<String> = []
    init(dictionary: [String: AnyObject]) {
        self.createdAt = dictionary["createdAt"] as? String
        if let arr = (dictionary["participants"] as? Array<String>) {
            self.participants = arr
        }
    }
    
    func isEqualTo(conversation: ConversationsTable) -> Bool {
        if self.participants.count != conversation.participants.count {
            return false
        }
        for i in 0..<self.participants.count {
            if self.participants[i] != conversation.participants[i] {
                return false
            }
        }
        return true
    }
}
