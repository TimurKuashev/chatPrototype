//
//  CacheManager.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 09.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation
import FirebaseStorage

class CacheManager {
    
    static let shared = CacheManager()
    private init() { }
    
    var savedImages: Dictionary<String, UIImage?> = [:]
    var savedDocuments: Dictionary<String, Data> = [:]
    
    func loadAndSaveImage(stringUrl: String?, dataType: MessagesTable.MessagesTypes, successHandler: @escaping () -> Void, errorHandler: @escaping (_ error: Error) -> Void) {
        guard let stringUrl = stringUrl else { return }
        Storage.storage().reference(forURL: stringUrl).getData(maxSize: INT64_MAX) {
            (data: Data?, error: Error?) in
            guard error == nil else {
                errorHandler(error!)
                return
            }
            if let unwrappedData = data {
                switch dataType {
                case .image:
                    self.savedImages[String(describing: stringUrl)] = UIImage(data: unwrappedData)
                case .document:
                    self.savedDocuments[String(describing: stringUrl)] = unwrappedData
                default: break
                }
            } else {
                self.savedImages[String(describing: stringUrl)] = UIImage(named: "empty_image")
            }
            successHandler()
        }
        
    }
    
    
}
