//
//  LocationPickerViewController.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 23.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import GoogleMaps

protocol LocationPickerViewControllerDelegate: AnyObject {
    func sendLocation(coordinates: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    
    // MARK: - Properties
    private var mapView: GMSMapView!
    private lazy var btnAttachMyLocation: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1.5
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.setTitle("Send location", for: .normal)
        return btn
    }()
    
    private lazy var ivSelectedPlace: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "icon_red_placemark")
        iv.backgroundColor = .clear
        iv.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return iv
    }()
    
    private var locManager = LocationManager()
    weak var delegate: LocationPickerViewControllerDelegate?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigure()
    }
    
    private func initialConfigure() {
        locManager.delegate = self
        locManager.requestLocation()
        btnAttachMyLocation.addTarget(self, action: #selector(sendLocationPressed(_:)), for: .touchUpInside)
        HudManager.showOnFullScreen()
    }
    
    @objc private func sendLocationPressed(_ sender: UIButton) {
        self.delegate?.sendLocation(coordinates: mapView.camera.target)
    }
    
}

// MARK: - LocationManagerDelegate
extension LocationPickerViewController: LocationManagerDelegate {
    
    func currentLocationFetchingSuccess(location: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 20)
            self.mapView = GMSMapView(frame: CGRect.zero, camera: camera)
            self.view.addSubview(self.mapView)
            self.view.addSubview(self.btnAttachMyLocation)
            self.view.addSubview(self.ivSelectedPlace)
            self.mapView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                // Map
                self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.view.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor),
                self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                // Button "Send Location"
                self.btnAttachMyLocation.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.btnAttachMyLocation.widthAnchor.constraint(equalToConstant: 150),
                self.view.bottomAnchor.constraint(equalTo: self.btnAttachMyLocation.bottomAnchor, constant: 20),
                self.btnAttachMyLocation.heightAnchor.constraint(equalToConstant: 40),
                // The red placemark in the middle of the map
                self.ivSelectedPlace.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.ivSelectedPlace.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = location
            marker.title = "You"
            marker.snippet = "Current Location"
            marker.map = self.mapView
            HudManager.hideFromFullScreen()
        }
    }
    
    func currentLocationFetchingFail(error: Error?) {
        self.presentAlert(title: "Error", message: error?.localizedDescription ?? "Some error occurs", actions: [], displayCloseButton: true)
    }
    
}
