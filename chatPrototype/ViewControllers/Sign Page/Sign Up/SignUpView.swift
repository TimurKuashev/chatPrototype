//
//  SignUpView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class SignUpView: UIView {
    
    private var usernameTextField: UITextField = {
        let usernameTextField = UITextField()
        usernameTextField.layer.cornerRadius = 5
        usernameTextField.placeholder = "Username"
        usernameTextField.font = UIFont(name: "Times New Roman", size: 20)
        usernameTextField.layer.borderWidth = 1.0
        usernameTextField.layer.borderColor = UIColor.likePlaceholderTextColor.cgColor
        usernameTextField.autocapitalizationType = .none
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        return usernameTextField
    }()
    
    private var emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email"
        emailTextField.font = UIFont(name: "Times New Roman", size: 20)
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.likePlaceholderTextColor.cgColor
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        return emailTextField
    }()
    
    private var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.placeholder = "Password"
        passwordTextField.font = UIFont(name: "Times New Roman", size: 20)
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.likePlaceholderTextColor.cgColor
        passwordTextField.autocapitalizationType = .none
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
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
        setupUsernameTextField()
        setupEmailTextField()
        setupPasswordTextField()
    }
    
    private func setupUsernameTextField() {
        self.addSubview(usernameTextField)
        usernameTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        usernameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        usernameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func setupEmailTextField() {
        self.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 0).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor, constant: 0).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor, constant: 0).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func setupPasswordTextField() {
        self.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor, constant: 0).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: 0).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func getEnteredData() -> (username: String?, email: String?, password: String?) {
        return (usernameTextField.text, emailTextField.text, passwordTextField.text)
    }
    
}

