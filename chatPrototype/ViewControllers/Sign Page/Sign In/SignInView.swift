//
//  SignInView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class SignInView: UIView {
    
    private var emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email"
        emailTextField.font = UIFont(name: "Times New Roman", size: 25)
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22).cgColor
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        return emailTextField
    }()
    
    private var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.placeholder = "Password"
        passwordTextField.font = UIFont(name: "Times New Roman", size: 25)
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22).cgColor
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.autocapitalizationType = .none
        return passwordTextField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    private func initialConfigure() {
        // For dismiss keyboard when we tap on UIView free space
        self.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:)))
        )
        setupEmailTextField()
        setupPasswordTextField()
    }
    
    private func setupEmailTextField() {
        self.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        emailTextField.delegate = self
    }
    
    private func setupPasswordTextField() {
        self.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor, constant: 0).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: 0).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func getEnteredData() -> (email: String?, password: String?) {
        return (emailTextField.text, passwordTextField.text)
    }

}

// MARK: - UITextFieldDelegate
extension SignInView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.becomeFirstResponder()
        return true
    }
}
