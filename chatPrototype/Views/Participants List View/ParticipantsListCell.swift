//
//  ParticipantsListCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 19.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ParticipantsListCell: UITableViewCell {
    
    private var participantView: ParticipantView = ParticipantView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.layer.borderWidth = 0.0
        self.addSubview(participantView)
        participantView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            participantView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 0),
            participantView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            participantView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 0),
            participantView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: 0)
        ])
    }
    
    func set(userId: String?) {
        participantView.autoFill()
    }
    
}
