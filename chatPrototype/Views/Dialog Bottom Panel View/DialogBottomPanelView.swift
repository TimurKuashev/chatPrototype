//
//  DialogBottomPanelView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 05.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

protocol DialogBottomPanelViewDelegate: AnyObject {
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
    
    weak var delegate: DialogBottomPanelViewDelegate?
    private var isRecordActive: Bool = false
    
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
        tvTypeMessage.delegate = self
        updateButtonTitle()
    }
    
    @objc private func attachFilePressed(_ sender: UIButton!) {
        delegate?.showAttachmentMenu()
    }
    
    @objc private func sendMessageOrRecordVoiceMessagePressed(_ sender: UIButton!) {
        if (tvTypeMessage.text.count == 0) {
            if isRecordActive == false {
                delegate?.requestStartRecordVoiceMessage()
                tvTypeMessage.isUserInteractionEnabled = false
                isRecordActive = true
            }
            else {
                delegate?.requestCompleteRecordVoiceMessage()
                tvTypeMessage.isUserInteractionEnabled = true
                isRecordActive = false
            }
        } else {
            delegate?.requestSend(message: tvTypeMessage.text)
            tvTypeMessage.text = nil
            isRecordActive = false
        }
        updateButtonTitle()
    }
    
    // MARK: - Public Methods
    func getTextMessage() -> String? {
        return tvTypeMessage.text
    }
    
    private func updateButtonTitle() {
        if (tvTypeMessage.text.count == 0) {
            if isRecordActive == true {
                btnSendMessage.setTitle(nil, for: .normal)
                btnSendMessage.setImage(UIImage(named: "icon_stopRecordVoiceMessage"), for: .normal)
            } else {
                btnSendMessage.setTitle(nil, for: .normal)
                btnSendMessage.setImage(UIImage(named: "icon_startRecordVoiceMessage"), for: .normal)
            }
        } else {
            btnSendMessage.setTitle("Send", for: .normal)
            btnSendMessage.setImage(nil, for: .normal)
        }
    }
    
}

extension DialogBottomPanelView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateButtonTitle()
    }
}
