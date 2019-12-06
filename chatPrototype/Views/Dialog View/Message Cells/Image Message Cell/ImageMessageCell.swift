//
//  ImageMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 04.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class ImageMessageCell: UICollectionViewCell {

    @IBOutlet private var ivImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(image: UIImage?) {
        self.ivImage.image = image
    }
    
    

}
