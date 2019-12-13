//
//  SharedImagesViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 13.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

class SharedImagesViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout() )
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(SharedImageCell.self, forCellWithReuseIdentifier: CellIdentifiers.sharedImageCell)
        (cv.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
        return cv
    }()
    
    var imagesUrls: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    private func initialConfigure() {
        self.view.backgroundColor = .orange
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource
extension SharedImagesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.imagesUrls.count / 2 + (self.imagesUrls.count % 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.sharedImageCell, for: indexPath) as? SharedImageCell else {
            return UICollectionViewCell()
        }
        // section * items_in_line + row_number
        cell.set(image: CacheManager.shared.savedImages[self.imagesUrls[indexPath.section * 2 + indexPath.row] ?? ""] ?? UIImage(named: "empty_image"))
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension SharedImagesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}


// MARK: - Cell
class SharedImageCell: UICollectionViewCell {
    
    private lazy var sharedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }

    
    private func initialConfigure() {
        self.addSubview(sharedImage)
        sharedImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        sharedImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        sharedImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        sharedImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    
    func set(image: UIImage?) {
        self.sharedImage.image = image
    }
    
}
