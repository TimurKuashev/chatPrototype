//
//  TextMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

final class TextMessageCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    /// Where text message is display
    private var tvMessage: UITextView = {
        let iv = UITextView()
        iv.backgroundColor = .clear
        iv.isSelectable = true
        iv.isScrollEnabled = false
        iv.isEditable = false
        iv.textColor = .white
        iv.dataDetectorTypes = UIDataDetectorTypes.link
        iv.font = UIFont(name: "Times New Roman", size: 16)
        iv.textContainer.lineBreakMode = .byWordWrapping
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    /// Where all message views (like text view, sender icon (if it will be implemented) and other) contains
    private var customContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /*
     These constraint needs for moving the message to the left (if participant send this message)
     or to the right (if this message is our) side.
     */
    /// Leading constraint of the customContentView
    private var leadingConstraint: NSLayoutConstraint?
    /// Trailing constraint of the customContentView
    private var trailingConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupCell()
    }
    
    // MARK: - Methods
    private func setupCell() {
        self.addSubview(customContentView)
        customContentView.backgroundColor = .black
        customContentView.addSubview(tvMessage)
        tvMessage.delegate = self
        
        self.leadingConstraint = customContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        self.trailingConstraint = customContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([
            // Content View
            customContentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.leadingConstraint ?? customContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.trailingConstraint ?? customContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            customContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            // tvMessage
            tvMessage.topAnchor.constraint(equalTo: customContentView.topAnchor, constant: 5),
            customContentView.trailingAnchor.constraint(equalTo: tvMessage.trailingAnchor, constant: 10),
            customContentView.leadingAnchor.constraint(equalTo: tvMessage.leadingAnchor, constant: 10),
            tvMessage.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor, constant: 5)
        ])
    }
    
    func set(message: MessagesTable) {
        tvMessage.text = message.text
        if message.sender == FirebaseAuthService.getUserId() {
            moveToRightSide()
        } else {
            moveToLeftSide()
        }
        tvMessage.sizeToFit()
        self.layoutIfNeeded()
        if message.isSeen == true {
            self.backgroundColor = .green
        } else {
            self.backgroundColor = .orange
        }
    }
    
    private func moveToLeftSide() {
        trailingConstraint?.isActive = false
//        tvMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
        leadingConstraint?.isActive = true
//        tvMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = false
        tvMessage.textAlignment = .left
    }
    
    private func moveToRightSide() {
        leadingConstraint?.isActive = false
//        tvMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
        trailingConstraint?.isActive = true
//        tvMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = false
        tvMessage.textAlignment = .right
    }
    
    func message() -> String? {
        return tvMessage.text
    }
    
}

// MARK: - UITextViewDelegate
extension TextMessageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    // Dynamic size
//    func textViewDidChange(_ textView: UITextView) {
//        print(textView.text)
//        let size = CGSize(width: self.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//
//        textView.constraints.forEach { (constraint) in
//            if constraint.firstAttribute == .height {
//                constraint.constant = estimatedSize.height
//            }
//        }
//    }
    
}
