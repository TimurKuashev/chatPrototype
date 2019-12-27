//
//  ParticipantView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 24.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import FirebaseDatabase

final class ParticipantView: UIView {
    
    // MARK: - Private Properties
    private var userAvatar: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 40
        iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return iv
    }()
    
    private var lblUsername: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var lblUserStatus: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .lightGray
        lbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
        self.addSubview(lblUserStatus)
        NSLayoutConstraint.activate([
            // User Avatar
            userAvatar.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 5),
            userAvatar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userAvatar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5),
            // Username
            lblUsername.topAnchor.constraint(equalTo: userAvatar.topAnchor),
            lblUsername.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 10),
            lblUsername.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
            // Online/Offline status
            lblUserStatus.topAnchor.constraint(equalTo: lblUsername.bottomAnchor, constant: 5),
            userAvatar.bottomAnchor.constraint(equalTo: lblUserStatus.bottomAnchor, constant: 10),
            lblUserStatus.leadingAnchor.constraint(equalTo: lblUsername.leadingAnchor),
            lblUserStatus.trailingAnchor.constraint(equalTo: lblUsername.trailingAnchor)
        ])
    }
    
}

// MARK: - Public Methods
extension ParticipantView {
    
    func set(username: String?, avatar: UIImage?) {
        lblUsername.text = username
        userAvatar.image = avatar ?? UIImage(named: "empty_user_avatar")
    }
    
    func autoFill(byUserId userId: String? = nil) {
        HudManager.push(to: self)
        self.userAvatar.image = UIImage(named: "empty_user_avatar")
        let id = userId ?? FirebaseAuthService.getUserId()
        fetchUserInfo(userId: id) {
            [weak self] (username: String?, status: String?) in
            guard let self = self else {
                return
            }
            HudManager.pop(from: self)
            self.lblUsername.text = username ?? ""
            self.lblUserStatus.text = status ?? ""
        }
    }
    
    private func fetchUserInfo(userId: String?, completion: @escaping (_ username: String?, _ status: String?) -> Void) {
        guard let userId = userId else {
            completion(nil, nil)
            return
        }
        Database.database().reference().child(FirebaseTableNames.users).child(userId).observeSingleEvent(of: .value) {
            (snapshot: DataSnapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                completion(nil, nil)
                return
            }
            completion(dictionary["username"] as? String, dictionary["status"] as? String)
        }
    }
    
}
