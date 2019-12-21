//
//  ParticipantsListCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 19.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ParticipantsListCell: UITableViewCell {
    
    private var lblUsername = UILabel()
    private var userAvatar = UIImageView()
    
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
        self.addSubview(lblUsername)
        lblUsername.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lblUsername.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 0),
            lblUsername.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            lblUsername.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 0),
            lblUsername.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: 0)
        ])
        lblUsername.textColor = .white
        lblUsername.font = UIFont(name: "Times New Roman", size: 25)
        
    }
    
    func set(username: String?) {
        self.lblUsername.text = username ?? "Unknown"
    }
    
}
