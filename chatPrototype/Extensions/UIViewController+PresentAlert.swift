//
//  UIViewController+PresentAlert.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func presentAlert(title: String?, message: String?, actions: [UIAlertAction], displayCloseButton: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        if displayCloseButton {
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        present(alertController, animated: true, completion: nil)
    }

}
