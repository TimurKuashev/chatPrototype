//
//  FindedMessagesViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 13.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class FindedMessagesViewController: UIViewController{
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(FindedMessageCell.self, forCellReuseIdentifier: CellIdentifiers.findedMessageCell)
        return tv
    }()
    
    var messages: [MessagesTable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    private func initialConfigure() {
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension FindedMessagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.findedMessageCell, for: indexPath) as? FindedMessageCell else {
            return UITableViewCell()
        }
        cell.set(text: self.messages[indexPath.row].text)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension FindedMessagesViewController: UITableViewDelegate {
    
}

// MARK: - Cell
class FindedMessageCell: UITableViewCell {
    
    private var lblText: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
        self.addSubview(lblText)
        lblText.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        lblText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        lblText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        lblText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    func set(text: String?) {
        lblText.text = text
    }
    
}
