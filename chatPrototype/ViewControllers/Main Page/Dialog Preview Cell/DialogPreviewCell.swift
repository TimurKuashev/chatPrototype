//
//  DialogPreviewCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class DialogPreviewCell: UICollectionViewCell {

    @IBOutlet private var lblSenderName: UILabel!
    @IBOutlet private var lblMessage: UILabel!
    @IBOutlet private var lblSentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        lblSenderName.font = UIFont(name: "Times New Roman", size: 18)
        lblSenderName.textColor = .white
        lblMessage.textColor = UIColor(137, 140, 150)
        lblSentDate.textColor = UIColor(137, 140, 150)
    }
    
    func setup(lastSenderName: String?, lastMessage: String, lastMessageDate: String) {
        lblSenderName.text = lastSenderName ?? "You"
        lblMessage.text = lastMessage
        lblSentDate.text = lastMessageDate
    }
    
    
}
