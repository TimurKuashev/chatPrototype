//
//  FirebaseDataWritter.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Firebase

class FirebaseDataWritter {
    
    static func updateDataToRealtimeDatabase(data: inout [String: Any], toCollection collectionName: String, errorHandler: (() -> Void)? = nil) {
        guard let uID = FirebaseAuthService.getUserId() else {
            errorHandler?()
            return
        }
        Database.database().reference().child(collectionName).child(uID).setValue(data)
    }
    
    static func writeToLongstoreDatabase(data: inout [String: String], toCollection collectionName: String, errorHandler: (() -> Void)? = nil) {
        Firestore.firestore().collection(collectionName).addDocument(data: data)
    }
    
}
