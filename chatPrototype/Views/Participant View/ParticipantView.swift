//
//  ParticipantView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 24.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

final class ParticipantView: UIView {
    
    // MARK: - Private Properties
    private var userAvatar: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 40
        return iv
    }()
    
    private var lblUsername: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(userAvatar)
        self.addSubview(lblUsername)
        NSLayoutConstraint.activate([
            // User Avatar
            userAvatar.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            userAvatar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userAvatar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5),
            // Username
            lblUsername.topAnchor.constraint(equalTo: userAvatar.topAnchor),
            lblUsername.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 10),
            lblUsername.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5),
            lblUsername.bottomAnchor.constraint(equalTo: userAvatar.bottomAnchor)
        ])
    }
    
}

// MARK: - Public Methods
extension ParticipantView {
    
    func set(username: String?, avatar: UIImage?) {
        lblUsername.text = username
        userAvatar.image = avatar ?? UIImage(named: "empty_user_avatar")
    }
    
}
