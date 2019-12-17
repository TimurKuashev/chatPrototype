//
//  FirebaseTableNames.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

enum FirebaseTableNames {
    private static let rootTableName = "v2/"
    
    static var users = FirebaseTableNames.rootTableName + "users"
    static var tokens = FirebaseTableNames.rootTableName + "tokens"
    static var conversations = FirebaseTableNames.rootTableName + "conversations"
    static var usersConverstaions = FirebaseTableNames.rootTableName + "users_Conversations"
    static var messages = FirebaseTableNames.rootTableName + "messages"
    
    // MARK: - Storage
    static var imageMessages = FirebaseTableNames.rootTableName + "image_messages"
    static var documentMessages = FirebaseTableNames.rootTableName + "document_messages"
    static var voiceMessages = FirebaseTableNames.rootTableName + "voice_messages"
    
}
