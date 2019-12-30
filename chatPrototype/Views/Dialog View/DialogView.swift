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
    func longPressOn(message: MessagesTable)
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
//        (messagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        messagesCollectionView.register(TextMessageCell.self, forCellWithReuseIdentifier: String(describing: TextMessageCell.self))
        messagesCollectionView.register(ImageMessageCell.self, forCellWithReuseIdentifier: String(describing: ImageMessageCell.self))
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.documentMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.documentMessageCell)
        messagesCollectionView.register(VoiceMessageCell.self, forCellWithReuseIdentifier: CellIdentifiers.voiceMessageCell)
        
        let longPressGesRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressTriggered(_:)) )
        messagesCollectionView.addGestureRecognizer(longPressGesRecognizer)
    }
    
    @objc private func longPressTriggered(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let p = gesture.location(in: self.messagesCollectionView)
        guard let indexPath = self.messagesCollectionView.indexPathForItem(at: p) else {
            return
        }
        // let cell = self.messagesCollectionView.cellForItem(at: indexPath)
        self.delegate?.longPressOn(message: self.dataSource.messages[indexPath.row])
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
        switch self.dataSource.messages[indexPath.section].type {
        case .image:
            return CGSize(width: 200, height: 200)
        case .document:
            return CGSize(width: 80, height: 80)
        case .location:
            return CGSize(width: 200, height: 150)
        case .voice:
            return CGSize(width: 150, height: 60)
        default:
            return CGSize(width: collectionView.bounds.width - 30, height: 100)
        }
//        let size = CGSize(width: collectionView.bounds.width - 30, height: 10)
//        return size
//        return collectionView.sizeThatFits(size)
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
