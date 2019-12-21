//
//  PinterestView.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 21.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit

final class PinterestView: UIView {
    
    private let pinterestLayout: PinterestLayout
    private var collectionView: UICollectionView
    private var images: [UIImage] = []
    
    override init(frame: CGRect) {
        pinterestLayout = PinterestLayout()
        collectionView = UICollectionView(frame: frame, collectionViewLayout: pinterestLayout)
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        pinterestLayout = PinterestLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: pinterestLayout)
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor(161, 167, 171, 0.7)
        collectionView.backgroundColor = UIColor(161, 167, 171, 0.7)
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: String(describing: PinterestCell.self) )
        collectionView.dataSource = self
        collectionView.delegate = self
        pinterestLayout.delegate = self
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ])
    }
    
    func set(images: [UIImage]) {
        self.images = images
        collectionView.reloadData()
    }
    
}


// MARK: - UICollectionViewDataSource
extension PinterestView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PinterestCell.self), for: indexPath) as? PinterestCell else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PinterestCell.self), for: indexPath)
            cell.backgroundColor = .yellow
            return cell
        }
        cell.set(image: self.images[indexPath.row])
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension PinterestView: UICollectionViewDelegate {
    
}

// MARK: - PinterestLayoutDelegate
extension PinterestView: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAt indexPath: IndexPath) -> CGFloat {
        return self.images[indexPath.row].size.height
    }
}
