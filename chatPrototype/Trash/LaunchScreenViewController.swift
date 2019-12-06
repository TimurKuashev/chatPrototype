//
//  LaunchScreenViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let vc = SignPage(nibName: "SignPage", bundle: nil)
            self.present(vc, animated: true)
        }
    }
    
}
