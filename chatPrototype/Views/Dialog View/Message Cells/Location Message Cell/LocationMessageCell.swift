//
//  LocationMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 27.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationMessageCell: UICollectionViewCell {
    
    private lazy var tvPlaceDescription: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Times New Roman", size: 14)
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.backgroundColor = .white
        tv.textColor = .black
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return  tv
    }()
    
    private var mapView: GMSMapView!
    
    func set(coordinates: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 20.0)
        self.mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        self.addSubview(mapView)
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.mapView.topAnchor.constraint(equalTo: self.topAnchor),
            self.mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        let marker = GMSMarker()
        marker.position = coordinates
        marker.map = self.mapView
        
        
    }
    
}
