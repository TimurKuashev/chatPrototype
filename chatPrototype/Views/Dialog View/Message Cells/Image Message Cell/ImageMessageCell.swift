//
//  ImageMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ImageMessageCell: UICollectionViewCell {
    
    private var ivImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(ivImage)
        NSLayoutConstraint.activate([
            ivImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            ivImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ivImage.topAnchor.constraint(equalTo: self.topAnchor),
            ivImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func set(image: UIImage?, size: CGSize) {
        self.ivImage.image = image
        ivImage.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        ivImage.widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }
    
}
