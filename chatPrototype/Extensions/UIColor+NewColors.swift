//
//  UIColor+NewColors.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 06.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit


extension UIColor {
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    
    open class var likePlaceholderTextColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }
}
