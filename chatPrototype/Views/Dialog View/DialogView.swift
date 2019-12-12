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
}

class DialogView: UIView {
    
    // MARK: - @IBOutlets & Properties
    @IBOutlet private var messagesCollectionView: UICollectionView!
    private let dataSource = DialogViewDataSource()
    
    var delegate: DialogViewDelegate?
    
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
    
}

// MARK: - Private Methods
private extension DialogView {
    
    func initialConfigure() {
        self.loadFromNib()
        messagesCollectionView.backgroundColor = UIColor(red: 3.0 / 255.0, green: 37.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
        messagesCollectionView.delegate = self
        dataSource.delegate = self
        messagesCollectionView.dataSource = dataSource
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.textMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.textMessageCell)
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.imageMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.imageMessageCell)
        messagesCollectionView.register(UINib(nibName: CellIdentifiers.documentMessageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.documentMessageCell)
    }
    
}

// MARK: - DialogViewDataSourceDelegate
extension DialogView: DialogViewDataSourceDelegate {
    
    func newImageMessageComes(stringImageUrl: String?) {
        CacheManager.shared.loadAndSaveImage(
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
        CacheManager.shared.loadAndSaveImage(
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
    
    func newTextMessagesComes() {
        self.messagesCollectionView.reloadData()
    }
    
    func newVoiceMessageComes() {
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
