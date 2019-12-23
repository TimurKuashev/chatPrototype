//
//  PinterestCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 21.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

final class PinterestCell: UICollectionViewCell {
    
    private var displayedImage: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(255, 255, 255, 0.8)
        self.layer.cornerRadius = 15
        self.addSubview(displayedImage)
        displayedImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            displayedImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            displayedImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            displayedImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            displayedImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func set(image: UIImage) {
        displayedImage.image = image
    }
    
}
