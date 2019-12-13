//
//  UsersListViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 13.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol UsersListDelegate {
    func createChatPressed(with selectedUsersId: [String?])
}

class UsersListViewController: UIViewController {
    
    var users: [UsersTable] = []
    var delegate: UsersListDelegate?
    private var selectedUsersId: [String?] = []
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UserInfoCell.self, forCellReuseIdentifier: CellIdentifiers.userInfoCell)
        return table
    }()
    
    private var btnCreateChat: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        btn.layer.cornerRadius = 15
        btn.setTitle("Create Group Chat", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    private func initialConfigure() {
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.view.addSubview(btnCreateChat)
        btnCreateChat.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20).isActive = true
        btnCreateChat.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: btnCreateChat.bottomAnchor, constant: 0).isActive = true
        btnCreateChat.addTarget(self, action: #selector(self.createChat(_ :)), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    @objc private func createChat(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.createChatPressed(with: self.selectedUsersId)
    }
    
}

// MARK: - UITableViewDataSource
extension UsersListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.userInfoCell, for: indexPath) as? UserInfoCell else {
            return UITableViewCell()
        }
        cell.set(userName: self.users[indexPath.row].username, userId: users[indexPath.row].id)
        cell.delegate = self
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UserInfoCellDelegate
extension UsersListViewController: UserInfoCellDelegate {
    
    func userSelected(userId: String?) {
        self.selectedUsersId.append(userId)
    }
    
    func userDeselected(userId: String?) {
        guard let index = self.selectedUsersId.firstIndex(of: userId) else { return }
        self.selectedUsersId.remove(at: index)
    }
    
}

// MARK: - Cell
protocol UserInfoCellDelegate: AnyObject {
    func userSelected(userId: String?)
    func userDeselected(userId: String?)
}
class UserInfoCell: UITableViewCell {
    
    var delegate: UserInfoCellDelegate?
    private var isCheckboxSelected: Bool = false
    private var userId: String?
    
    private var lblUsername: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "Times New Roman", size: 20)
        return lbl
    }()
    
    private var checkbox: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 3.0
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.backgroundColor = UIColor.clear.cgColor
        btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    private func initialConfigure() {
        self.addSubview(lblUsername)
        lblUsername.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        lblUsername.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        lblUsername.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        self.addSubview(checkbox)
        checkbox.addTarget(self, action: #selector(onCheckboxTapped(_ :)), for: .touchUpInside)
        checkbox.topAnchor.constraint(equalTo: lblUsername.topAnchor, constant: 0).isActive = true
        checkbox.bottomAnchor.constraint(equalTo: lblUsername.bottomAnchor, constant: 0).isActive = true
        checkbox.leadingAnchor.constraint(greaterThanOrEqualTo: lblUsername.trailingAnchor, constant: 50).isActive = true
        self.trailingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 5).isActive = true
    }
    
    @objc private func onCheckboxTapped(_ sender: UIButton?) {
        isCheckboxSelected = !isCheckboxSelected
        if (isCheckboxSelected == true) {
            self.delegate?.userSelected(userId: self.userId)
            checkbox.layer.backgroundColor = UIColor.green.cgColor
        } else {
            self.delegate?.userDeselected(userId: self.userId)
            checkbox.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    func set(userName: String?, userId: String?) {
        self.lblUsername.text = userName
        self.userId = userId
    }
    
}
