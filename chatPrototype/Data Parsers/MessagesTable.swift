//
//  MessagesTable.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

class MessagesTable {
    
    enum MessagesTypes: String {
        case text = "text"
        case image = "image"
        case location = "location"
        case document = "document"
        case unknown = "unknown"
        
        static func getType(typeDescription: String?) -> MessagesTypes {
            guard let typeDescription = typeDescription else {
                return .unknown
            }
            switch typeDescription {
            case "text":
                return .text
            case "image":
                return .image
            case "location":
                return .location
            case "document":
                return .document
            default:
                return .unknown
            }
        }
    }

    var type: MessagesTypes
    var createdAt: String?
    var imageURL: String?
    var isSeen: Bool?
    var sender: String?
    var text: String?
        
    init(dictionary: Dictionary<String, AnyObject>) {
        self.createdAt = dictionary["createdAt"] as? String
        self.imageURL = dictionary["imageURL"] as? String
        self.isSeen = dictionary["isSeen"] as? Bool
        self.sender = dictionary["sender"] as? String
        self.text = dictionary["text"] as? String
        self.type = MessagesTypes.getType(typeDescription: dictionary["type"] as? String)
    }
}
