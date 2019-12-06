//
//  SignPage.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import FirebaseAuth

final class SignPage: UIViewController {
    
    // MARK: - @IBOutlets & Private Properties
    @IBOutlet private var loginRegisterSegController: UISegmentedControl!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var btnAction: UIButton!
    
    private var signInView: SignInView = SignInView()
    private lazy var signUpView: SignUpView = SignUpView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (UserDefaults.standard.value(forKey: CustomPropertiesForUserDefaults.isSignIn) as? Bool) == true {
            goToHomePage()
        }
    }
    
    deinit {
        btnAction.removeTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        btnAction.removeTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Private Methods
private extension SignPage {
    
    // MARK: - GUI
    func initialConfigure() {
        containerView.layer.cornerRadius = 5
        
        loginRegisterSegController.setTitle("Sign In", forSegmentAt: 0)
        loginRegisterSegController.setTitle("Sign Up", forSegmentAt: 1)
        loginRegisterSegController.addTarget(self, action: #selector(tabNumberChanged(_:)), for: .valueChanged)
        loginRegisterSegController.selectedSegmentIndex = 0
        loginRegisterSegController.tintColor = .blue
        
        btnAction.setTitle("Sign In", for: .normal)
        btnAction.titleLabel?.font = UIFont(name: "Times New Roman", size: 25)
        btnAction.layer.cornerRadius = 10
        btnAction.backgroundColor = .blue
        btnAction.tintColor = .white
        btnAction.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
        
        // When keyboard is will appear, we should move to up all our views
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        // When keyboard is will disappear, we should move to down all our views
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addToContainer(view: signInView)
    }
    
    @objc func tabNumberChanged(_ segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0: // Sign In
            removeFromContainer(view: signUpView)
            addToContainer(view: signInView)
            btnAction.setTitle("Sign In", for: .normal)
            btnAction.removeTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
            btnAction.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
        case 1: // Sign Up
            removeFromContainer(view: signInView)
            addToContainer(view: signUpView)
            btnAction.setTitle("Sign Up", for: .normal)
            btnAction.removeTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
            btnAction.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        default: break
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: btnAction.frame.maxY - self.view.bounds.height + keyboardFrame.height + 30), animated: true)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: btnAction.frame.maxY - self.view.bounds.height + keyboardFrame.height - scrollView.contentOffset.y), animated: true)
    }
    
    private func removeFromContainer(view: UIView) {
        view.removeFromSuperview()
    }
    
    private func addToContainer(view: UIView) {
        self.containerView.addSubview(view)
        view.frame = self.containerView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func goToHomePage() {
        let vc = MainPageViewController(nibName: XibNameHelpers.mainPage, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // MARK: - Sign In/Up
    @objc func signIn(_ sender: UIButton!) {
        let enteredData = signInView.getEnteredData()
        guard enteredData.email != nil, enteredData.password != nil else {
            self.presentAlert(title: nil, message: "Bad credentials", actions: [], displayCloseButton: true)
            return
        }
        FirebaseAuthService.signIn(
            email: enteredData.email!,
            password: enteredData.password!,
            successHandler: {
                [weak self](result: AuthDataResult?) in
                UserDefaults.standard.set(enteredData.email!, forKey: CustomPropertiesForUserDefaults.email)
                UserDefaults.standard.set(enteredData.password!, forKey: CustomPropertiesForUserDefaults.password)
                UserDefaults.standard.set(true, forKey: CustomPropertiesForUserDefaults.isSignIn)
                guard let self = self else { return }
                self.goToHomePage()
        },
            errorHandler: {
                [weak self] (error) in
                guard let self = self else { return }
                self.presentAlert(title: "Error", message: error!.localizedDescription, actions: [], displayCloseButton: true)
        })
    }
    
    @objc func signUp(_ sender: UIButton!) {
        let enteredData = signUpView.getEnteredData()
        guard enteredData.username != nil, enteredData.email != nil, enteredData.password != nil else {
            self.presentAlert(title: nil, message: "Bad credentials", actions: [], displayCloseButton: true)
            return
        }
        FirebaseAuthService.createUser(
            email: enteredData.email!,
            password: enteredData.password!,
            successHandler: {
                [weak self](result: AuthDataResult?) in
                guard let self = self else { return }
                guard let uID = FirebaseAuthService.getUserId() else {
                    self.presentAlert(title: "Error", message: "Sorry, something went wrong. Please try again later", actions: [], displayCloseButton: true)
                    return
                }
                UserDefaults.standard.set(enteredData.email!, forKey:CustomPropertiesForUserDefaults.email)
                UserDefaults.standard.set(enteredData.password, forKey: CustomPropertiesForUserDefaults.password)
                UserDefaults.standard.set(enteredData.username!, forKey: CustomPropertiesForUserDefaults.username)
                var data: [String: Any] = [
                    "id": uID,
                    "status": "online",
                    "username": enteredData.username!
                ]
                FirebaseDataWritter.writeToRealtimeDatabase(data: &data, toCollection: FirebaseTableNames.users)
                FirebaseAuthService.signIn(
                    email: enteredData.email!,
                    password: enteredData.password!,
                    successHandler: {
                        [weak self](result: AuthDataResult?) in
                        UserDefaults.standard.set(true, forKey: CustomPropertiesForUserDefaults.isSignIn)
                        guard let self = self else { return }
                        self.goToHomePage()
                },
                    errorHandler: {
                        [weak self] (error) in
                        guard let self = self else { return }
                        self.presentAlert(title: "Error", message: error!.localizedDescription, actions: [], displayCloseButton: true)
                })
            }, errorHandler: {
                [weak self] (error) in
                guard let self = self else { return }
                self.presentAlert(title: nil, message: error!.localizedDescription, actions: [], displayCloseButton: true)
        })
    }
    
}
