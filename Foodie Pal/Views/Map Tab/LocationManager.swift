//
//  LocationManager.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-20.
//

import Foundation
import CoreLocation


class LocationManager : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var location : CLLocationCoordinate2D?
    
    //overridar init i NSObject
    //kallar på konstruktören i NSObect (super.init())
    override init() {
        super.init()
        manager.delegate = self
        
        
    }
    
    func startLocationUpdates() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        print("Plats uppdaterad \(location)")
    }
    
}
