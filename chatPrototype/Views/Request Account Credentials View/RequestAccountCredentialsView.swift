//
//  RequestAccountCredentialsView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class RequestAccountCredentialsView: UIView {

    @IBOutlet private var lblEmailTitle: UILabel!
    @IBOutlet private var tfEmail: UITextField!
    @IBOutlet private var lblPasswordTitle: UILabel!
    @IBOutlet private var tfPassword: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    private func initialConfigure() {
        loadFromNib()
        self.backgroundColor = .clear
        lblEmailTitle.text = "Email"
        tfEmail.placeholder = "example@email.com"
        lblPasswordTitle.text = "Password"
        tfPassword.placeholder = "Enter your password"
    }
    
    func setLabelTitles(firstLabelTitle: String?, secondLabelTitle: String?) {
        if firstLabelTitle != nil {
            lblEmailTitle.text = firstLabelTitle
        }
        if secondLabelTitle != nil {
            lblPasswordTitle.text = secondLabelTitle
        }
    }
    
    func getEnteredData() -> (email: String?, password: String?) {
        return (tfEmail.text, tfPassword.text)
    }
    
}
