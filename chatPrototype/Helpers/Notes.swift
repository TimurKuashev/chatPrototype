//
//  Заметки.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

/*
 Что бы добавить данные для постоянного хранения надо делать так:
 let data: [String: String] = [
     "id": Auth.auth().currentUser!.uid,
     "status": "offline",
     "username": "tempName"
 ]
 let db = Firestore.firestore()
 db.collection("users").addDocument(data: data)
 
 Что бы получить uID надо делать так:
 let userID = Auth.auth().currentUser!.uid
 
 Вложенность делается так:
 var data: [String: Any] = [
     "createdAt": Date().timeIntervalSince1970.description
 ]
 let tempData = [
     "0": FirebaseAuthService.getUserId(),
     "1": FirebaseAuthService.getUserId()
 ]
 data["participants"] = tempData
 FirebaseDataWritter.writeToRealtimeDatabase(data: &data, toCollection: FirebaseTableNames.conversations)
 В результате мы получим словарь с массивом, то есть мы должны кастануть так: (dictionary["participants"] as? Array<String>)?[0]

 
 */


