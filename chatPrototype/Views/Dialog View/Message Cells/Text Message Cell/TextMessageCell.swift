//
//  TextMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class TextMessageCell: UICollectionViewCell {

    @IBOutlet private var lblMessage: UILabel!
    @IBOutlet private var viewWithContent: UIView!
    @IBOutlet private var customContentView: UIView!
    @IBOutlet private var leftConstraint: NSLayoutConstraint!
    @IBOutlet private var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialConfigure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    private func initialConfigure() {
    }
    
    func set(text: String?, senderID: String?) {
        self.lblMessage.text = text
        self.lblMessage.textColor = .white
        self.customContentView.layer.cornerRadius = 10
        if senderID == FirebaseAuthService.getUserId() {
            moveToRightSide()
        } else {
            moveToLeftSide()
        }
    }
    
    private func moveToLeftSide() {
        leftConstraint.isActive = true
        rightConstraint.isActive = false
        lblMessage.textAlignment = .left
        customContentView.backgroundColor = UIColor(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    }
    
    private func moveToRightSide() {
        rightConstraint.isActive = true
        leftConstraint.isActive = false
        lblMessage.textAlignment = .right
        customContentView.backgroundColor = UIColor(red: 0 / 255.0, green: 89.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }
    
    func message() -> String? {
        return lblMessage.text
    }

}
