//
//  LocationManager.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 12.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func currentLocationFetchingSuccess(location: CLLocationCoordinate2D)
    func currentLocationFetchingFail(error: Error?)
}

class LocationManager: NSObject {
    
    weak var delegate: LocationManagerDelegate?
    private lazy var locManager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    func requestLocation() {
        locManager.requestLocation()
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        self.delegate?.currentLocationFetchingSuccess(location: locValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.currentLocationFetchingFail(error: error)
    }
    
}
