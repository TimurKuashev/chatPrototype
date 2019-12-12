//
//  DocumentMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 12.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class DocumentMessageCell: UICollectionViewCell {

    @IBOutlet private var lblDocumentName: UILabel!
    @IBOutlet private var ivDocumentTypeImageView: UIImageView!
    
    @IBOutlet private var customContentView: UIView!
    @IBOutlet private var leftConstraint: NSLayoutConstraint!
    @IBOutlet private var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(documentName: String, senderId: String?) {
        self.lblDocumentName.textColor = .white
        self.lblDocumentName.text = documentName
        self.layer.cornerRadius = 10
        if senderId == FirebaseAuthService.getUserId() {
            moveToRightSide()
        } else {
            moveToLeftSide()
        }
    }
    
    private func moveToLeftSide() {
        leftConstraint.isActive = true
        rightConstraint.isActive = false
        customContentView.backgroundColor = UIColor(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    }
    
    private func moveToRightSide() {
        rightConstraint.isActive = true
        leftConstraint.isActive = false
        customContentView.backgroundColor = UIColor(red: 0 / 255.0, green: 89.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }
    
}
