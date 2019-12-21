//
//  ParticipantsListView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 19.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol ParticipantsListViewDelegate: AnyObject {
    func hideButtonPressed(buttonOwner: ParticipantsListView)
}

class ParticipantsListView: UIView {
    
    private var participants: [UsersTable] = []
    private var tableView: UITableView = UITableView()
    private var btnHide: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .black
        btn.setTitleColor(.yellow, for: .normal)
        btn.setTitle(">>", for: .normal)
        return btn
    }()
    
    weak var delegate: ParticipantsListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(btnHide)
        btnHide.addTarget(self, action: #selector(hideButtonPressed(_ :)), for: .touchUpInside)
        btnHide.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        btnHide.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.addSubview(tableView)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: self.btnHide.centerXAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        tableView.register(ParticipantsListCell.self, forCellReuseIdentifier: String(describing: ParticipantsListCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func hideButtonPressed(_ sender: UIButton) {
        self.removeFromSuperview()
        self.delegate?.hideButtonPressed(buttonOwner: self)
    }
    
    private func setupTableViewSize() {
        
    }
    
    func set(participants: [UsersTable]) {
        self.participants = participants
        self.tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource
extension ParticipantsListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ParticipantsListCell.self), for: indexPath) as? ParticipantsListCell else {
            return tableView.dequeueReusableCell(withIdentifier: String(describing: ParticipantsListCell.self), for: indexPath)
        }
        cell.set(username: self.participants[indexPath.row].username)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ParticipantsListView: UITableViewDelegate {
    
}
