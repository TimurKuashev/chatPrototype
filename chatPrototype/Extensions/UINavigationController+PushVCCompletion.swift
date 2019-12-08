//
//  UINavigationController+PushVCCompletion.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 08.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

extension UINavigationController {

  public func pushViewController(_ viewController: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }

}
