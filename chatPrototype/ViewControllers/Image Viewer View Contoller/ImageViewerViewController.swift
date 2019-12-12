//
//  ImageViewerViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 12.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ImageViewerViewController: UIViewController {
    
    private var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    func set(image: UIImage?) {
        self.imageView.image = image
    }    
    
}
