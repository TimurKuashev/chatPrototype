//
//  UsersTable.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

class UsersTable: NSObject {
    var id: String?
    var username: String?
    var status: String?
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.username = dictionary["username"] as? String
        self.status = dictionary["status"] as? String
    }
}
