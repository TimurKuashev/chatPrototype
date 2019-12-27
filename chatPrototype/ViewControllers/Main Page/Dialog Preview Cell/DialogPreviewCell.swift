//
//  DialogPreviewCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class DialogPreviewCell: UICollectionViewCell {

    @IBOutlet private var userView: ParticipantView!
    @IBOutlet private var lblMessage: UILabel!
    @IBOutlet private var lblSentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        lblMessage.textColor = UIColor(137, 140, 150)
        lblSentDate.textColor = UIColor(137, 140, 150)
    }
    
    func setup(participantId: String?, lastMessage: String, lastMessageDate: String) {
        userView.autoFill(byUserId: participantId)
        lblMessage.text = lastMessage
        lblSentDate.text = lastMessageDate
    }
    
}
