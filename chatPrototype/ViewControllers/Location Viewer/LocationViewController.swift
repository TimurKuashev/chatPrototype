//
//  LocationViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 23.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationViewController: UIViewController {

    private var mapView: GMSMapView!
    private var locManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    private func initialConfigure() {
//        locManager.delegate = self
//        locManager.requestLocation()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    
    
}

extension LocationViewController: LocationManagerDelegate {
    
    func currentLocationFetchingSuccess(location: CLLocationCoordinate2D) {
        DispatchQueue.main.async {

        }
    }
    
    func currentLocationFetchingFail(error: Error?) {
        print(error!)
    }
    
}
