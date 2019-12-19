//
//  ContextMenuView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 18.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol ContextMenuViewDelegate: AnyObject {
    func didSelectItem(at: IndexPath)
}

class ContextMenuView: UIView {
    
    private let contextMenuCellIdentifier = "ContextMenuCell"
    weak var delegate: ContextMenuViewDelegate?
    private var items: Array<(title: String, icon: UIImage?)> = []
    
    private let tableViewWidth: CGFloat = 200
    private let tableViewHeight: CGFloat = 200
    
    private var tableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContextMenuCell.self, forCellReuseIdentifier: contextMenuCellIdentifier)
        
        tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: self.tableViewWidth).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: self.tableViewHeight).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func attachTo(parent: UIView, toLeftSide: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0).isActive = true
        if toLeftSide == true {
            self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        } else {
            parent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20).isActive = true
//            self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 20).isActive = true
        }
    }
    
    
    func addItem(title: String, icon: UIImage?) {
        self.items.append( (title: title, icon: icon) )
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource
extension ContextMenuView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContextMenuCell", for: indexPath) as? ContextMenuCell else {
            return tableView.dequeueReusableCell(withIdentifier: "ContextMenuCell", for: indexPath)
        }
        cell.set(title: self.items[indexPath.row].title, icon: self.items[indexPath.row].icon)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ContextMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.delegate?.didSelectItem(at: indexPath)
    }
}
