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
    var savedVoiceMessages: Dictionary<String, Data> = [:]
    
    func loadAndSaveData(stringUrl: String?, dataType: MessagesTable.MessagesTypes, successHandler: @escaping () -> Void, errorHandler: @escaping (_ error: Error) -> Void) {
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
                    self.savedImages[stringUrl] = UIImage(data: unwrappedData)
                case .document:
                    self.savedDocuments[stringUrl] = unwrappedData
                case .voice:
                    self.savedVoiceMessages[stringUrl] = unwrappedData
                default: break
                }
            } else {
                if dataType == .image {
                    self.savedImages[stringUrl] = UIImage(named: "empty_image")
                }
            }
            successHandler()
        }
        
    }
    
    
}
