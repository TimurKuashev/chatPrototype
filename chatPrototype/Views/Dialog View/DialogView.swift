//
//  DialogView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import Firebase

protocol DialogViewDelegate: AnyObject {
    func onImageClicked(message: MessagesTable)
    func onTextClicked(message: MessagesTable)
    func dialogStateChanged(lastMesage: MessagesTable?)
}

class DialogView: UIView {
    
    // MARK: - @IBOutlets & Properties
    @IBOutlet private var messagesCollectionView: UICollectionView!
    private let dataSource = DialogViewDataSource()
    
    weak var delegate: DialogViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    // MARK: - Public Methods
    func setConversation(id: String?) {
        dataSource.loadDataWith(conversationId: id)
    }
    
    
    func getImagesUrls(writeSpace: inout [String?]) {
        for message in dataSource.messages {
            writeSpace.append(message.imageURL)
        }
    }
}

// MARK: - Private Methods
private extension DialogView {
    
    func initialConfigure() {
        self.loadFromNib()
        messagesCollectionView.backgroundColor = .white
        messagesCollectionView.delegate = self
        dataSource.delegate = self
        messagesCollectionView.dataSource = dataSource
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.textMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.textMessageCell)
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.imageMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.imageMessageCell)
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.documentMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.documentMessageCell)
        messagesCollectionView.register(VoiceMessageCell.self, forCellWithReuseIdentifier: CellIdentifiers.voiceMessageCell)
    }
    
}

// MARK: - DialogViewDataSourceDelegate
extension DialogView: DialogViewDataSourceDelegate {
    func newVoiceMessageComes() {
        
    }
    
    
    func newImageMessageComes(stringImageUrl: String?) {
        CacheManager.shared.loadAndSaveData(
            stringUrl: stringImageUrl,
            dataType: .image,
            successHandler: {
                [weak self] in
                guard let self = self else { return }
                self.messagesCollectionView.reloadData()
            }, errorHandler: {
                (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func newDocumentMessageComes(stringDocumentUrl: String?) {
        CacheManager.shared.loadAndSaveData(
            stringUrl: stringDocumentUrl,
            dataType: .document,
            successHandler: {
                [weak self] in
                guard let self = self else { return }
                self.messagesCollectionView.reloadData()
            }, errorHandler: {
                (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func newVoiceMessageComes(stringVoiceMessageUrl: String?) {
        CacheManager.shared.loadAndSaveData(
            stringUrl: stringVoiceMessageUrl,
            dataType: .voice,
            successHandler: {
                [weak self] in
                guard let self = self else { return }
                self.messagesCollectionView.reloadData()
        },
            errorHandler: {
                (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func updateChat() {
        self.messagesCollectionView.reloadData()
        self.delegate?.dialogStateChanged(lastMesage: self.dataSource.messages.last)
    }
    
}

// MARK: - UICollecitonViewDelegate
extension DialogView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 30, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.dataSource.messages[indexPath.section].type {
        case .image:
            self.delegate?.onImageClicked(message: dataSource.messages[indexPath.section])
        case .text:
            self.delegate?.onTextClicked(message: dataSource.messages[indexPath.section])
        default: break
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DialogView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    
}
