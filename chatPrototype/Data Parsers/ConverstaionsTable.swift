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
    var participant0: String?
    var participant1: String?
    init(dictionary: [String: AnyObject]) {
        self.createdAt = dictionary["createdAt"] as? String
        self.participant0 = (dictionary["participants"] as? Array<String>)?[0]
        self.participant1 = (dictionary["participants"] as? Array<String>)?[1]
    }
    
    func isEqualTo(conversation: ConversationsTable) -> Bool {
        return (self.participant0 == conversation.participant0 && self.participant1 == conversation.participant1)
    }
}
