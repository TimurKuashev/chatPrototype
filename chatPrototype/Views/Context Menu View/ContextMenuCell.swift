//
//  ContextMenuCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 18.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ContextMenuCell: UITableViewCell {
    
    private lazy var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var iconView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    func set(title: String, icon: UIImage?) {
        self.backgroundColor = .clear
        self.iconView.removeFromSuperview()
        self.addSubview(iconView)
        if let icon = icon {
            self.iconView.image = icon
            iconView.widthAnchor.constraint(equalToConstant: 0).isActive = false
            iconView.heightAnchor.constraint(equalToConstant: 0).isActive = false
            iconView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            self.iconView.image = nil
            iconView.widthAnchor.constraint(equalToConstant: 20).isActive = false
            iconView.heightAnchor.constraint(equalToConstant: 20).isActive = false
            iconView.widthAnchor.constraint(equalToConstant: 0).isActive = false
            iconView.heightAnchor.constraint(equalToConstant: 0).isActive = false
        }
        
        iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        
        self.lblTitle.text = title
        self.lblTitle.removeFromSuperview()
        self.addSubview(lblTitle)
        lblTitle.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10).isActive = true
        lblTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }
}
