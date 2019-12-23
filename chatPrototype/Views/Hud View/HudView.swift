//
//  HudView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 23.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

final class HudManager {
    
    static func showOnFullScreen() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let fullscreenFrame = UIScreen.main.bounds
        let newHud = HudView(frame: fullscreenFrame)
        appDelegate.window?.addSubview(newHud)
    }
    
    static func hideFromFullScreen() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            HudManager.hideFromFullScreen()
            return
        }
        guard let subviews = appDelegate.window?.subviews else {
            return
        }
        
        for subview in subviews {
            if let hudSubview = subview as? HudView {
                hudSubview.removeFromSuperview()
                break
            }
        }
    }
    
    /// Appends a new hud to arg1 view
    /// - Parameter view: view, which will receive a new hud
    static func push(to view: UIView) {
        let hud = HudView(frame: view.frame)
        view.addSubview(hud)
        hud.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hud.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hud.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            hud.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hud.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    /// Remove a one hud from arg1 view
    /// - Parameter view: view, from which we will remove a one hud
    static func pop(from view: UIView) {
        for subview in view.subviews {
            if let hudSubview = subview as? HudView {
                hudSubview.removeFromSuperview()
                break
            }
        }
    }
    
    /// Remove all huds from arg1 view
    /// - Parameter view: view, from which we will remove all huds
    static func hide(from view: UIView) {
        for subview in view.subviews {
            if let hudSubview = subview as? HudView {
                hudSubview.removeFromSuperview()
            }
        }
    }
    
}

fileprivate final class HudView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(255,255,255, 0.3)
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.layer.cornerRadius = 15
        activityIndicator.layer.backgroundColor = UIColor.black.cgColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 70),
            activityIndicator.heightAnchor.constraint(equalToConstant: 70),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
        activityIndicator.startAnimating()
    }
    
}
