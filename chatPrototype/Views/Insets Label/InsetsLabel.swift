//
//  InsetsLabel.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class InsetsLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
    
}
