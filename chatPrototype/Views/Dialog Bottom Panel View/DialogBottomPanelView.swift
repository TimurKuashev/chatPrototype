//
//  DialogBottomPanelView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol DialogBottomPanelViewDelegate {
    func requestSendFile()
    func requestSend(message: String?)
    func requestRecordVoiceMessage()
}

final class DialogBottomPanelView: UIView {
    
    // MARK: - @IBOutlets & Properties
    @IBOutlet private var btnAttachFile: UIButton!
    @IBOutlet private var tvTypeMessage: UITextView!
    @IBOutlet private var btnSendMessage: UIButton!
    
    var delegate: DialogBottomPanelViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    // MARK: - Private Methods
    private func initialConfigure() {
        self.loadFromNib()
        btnAttachFile.addTarget(self, action: #selector(attachFilePressed(_:)), for: .touchUpInside)
        btnSendMessage.addTarget(self, action: #selector(sendMessageOrRecordVoiceMessagePressed(_:)), for: .touchUpInside)
        
        tvTypeMessage.layer.borderColor = UIColor.black.cgColor
        tvTypeMessage.layer.borderWidth = 1.0
        tvTypeMessage.layer.cornerRadius = 20
    }
    
    @objc private func attachFilePressed(_ sender: UIButton!) {
        delegate?.requestSendFile()
    }
    
    @objc private func sendMessageOrRecordVoiceMessagePressed(_ sender: UIButton!) {
        if tvTypeMessage.text == nil || tvTypeMessage.text == String() {
            delegate?.requestRecordVoiceMessage()
        } else {
            delegate?.requestSend(message: tvTypeMessage.text)
            tvTypeMessage.text = nil
        }
    }
    
    // MARK: - Public Methods
    func getTextMessage() -> String? {
        return tvTypeMessage.text
    }
    
}
