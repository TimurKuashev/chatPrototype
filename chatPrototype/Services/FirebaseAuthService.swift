//
//  FirebaseAuthService.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    
    static func createUser(email: String, password: String, successHandler: @escaping (_ result: AuthDataResult?) -> Void, errorHandler: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {
            (result, error) in
            if error == nil {
                successHandler(result)
            } else {
                errorHandler(error)
            }
        }
    }
    
    static func signIn(email: String, password: String, successHandler: @escaping (_ result: AuthDataResult?) -> Void, errorHandler: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (result: AuthDataResult?, error: Error?) in
            guard error == nil else {
                errorHandler(error! as NSError)
                return
            }
            successHandler(result)
        })
    }
    
    static func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
