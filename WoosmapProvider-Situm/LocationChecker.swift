//
//  LocationChecker.swift
//  WoosmapProvider-Situm
//
//  Created by WGS on 28/10/22.
//

import UIKit
import CoreLocation

protocol LocationCheckerProtocol {
    func LocationChecker(_ sender: LocationChecker, statusChange: CLAuthorizationStatus)
}

class LocationChecker: NSObject, CLLocationManagerDelegate {
    public var delegate: LocationCheckerProtocol?
    let manager: CLLocationManager = CLLocationManager()
    override init() {
        super.init()
        manager.delegate = self
    }
    
    fileprivate func askPermission() {
        if let backgroundModes =  Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? [String]{
            if (backgroundModes.contains("location")){
                manager.requestAlwaysAuthorization()
            }
        }
        if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") is String{
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocation(){
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied: // Setting option: Never
            print("LocationManager didChangeAuthorization denied")
        case .notDetermined: // Setting option: Ask Next Time
            print("LocationManager didChangeAuthorization notDetermined")
            askPermission()
        case .authorizedWhenInUse: // Setting option: While Using the App
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
        case .authorizedAlways: // Setting option: Always
            print("LocationManager didChangeAuthorization authorizedAlways")
        case .restricted: // Restricted by parental control
            print("LocationManager didChangeAuthorization restricted")
        default:
            print("LocationManager didChangeAuthorization")
        }
        delegate?.LocationChecker(self, statusChange: status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager didFailWithError \(error.localizedDescription)")
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            // To prevent forever looping of `didFailWithError` callback
            manager.stopMonitoringSignificantLocationChanges()
            return
        }
    }
}

