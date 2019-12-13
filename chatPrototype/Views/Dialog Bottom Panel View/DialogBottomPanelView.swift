//
//  DialogBottomPanelView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol DialogBottomPanelViewDelegate {
    func showAttachmentMenu()
    func requestSend(message: String?)
    func requestStartRecordVoiceMessage()
    func requestCompleteRecordVoiceMessage()
}

final class DialogBottomPanelView: UIView {
    
    // MARK: - @IBOutlets & Properties
    @IBOutlet private var btnAttachFile: UIButton!
    @IBOutlet private var tvTypeMessage: UITextView!
    @IBOutlet private var btnSendMessage: UIButton!
    
    var delegate: DialogBottomPanelViewDelegate?
    private var qwe: Bool = false
    
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
        
        btnSendMessage.setTitle(nil, for: .normal)
        btnSendMessage.setImage(UIImage(named: "icon_startRecord"), for: .normal)
    }
    
    @objc private func attachFilePressed(_ sender: UIButton!) {
        delegate?.showAttachmentMenu()
    }
    
    @objc private func sendMessageOrRecordVoiceMessagePressed(_ sender: UIButton!) {
        if tvTypeMessage.text == nil || tvTypeMessage.text == String() {
            if qwe == false {
                btnSendMessage.setTitle(nil, for: .normal)
                btnSendMessage.setImage(UIImage(named: "icon_stopRecord"), for: .normal)
                delegate?.requestStartRecordVoiceMessage()
                qwe = true
            } else {
                btnSendMessage.setImage(UIImage(named: "icon_startRecord"), for: .normal)
                delegate?.requestCompleteRecordVoiceMessage()
                qwe = false
            }
        } else {
            btnSendMessage.setImage(nil, for: .normal)
            btnSendMessage.setTitle("Send", for: .normal)
            delegate?.requestSend(message: tvTypeMessage.text)
            tvTypeMessage.text = nil
            qwe = false
        }
    }
    
    // MARK: - Public Methods
    func getTextMessage() -> String? {
        return tvTypeMessage.text
    }
    
}
