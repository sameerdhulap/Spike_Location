//
//  AppleLocationProvider.swift
//  Woosmap Location
//
//  Created by WGS on 27/10/22.
//

import UIKit
import CoreLocation

public class AppleLocationProvider: NSObject {
    public static let shared = AppleLocationProvider()
    private var manager: CLLocationManager = CLLocationManager()
    private var heading:Double = 0
    
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
    
    public func credential(_ keys:[String:String]){
        //Not implementated in this case, as Apple location not requires any special authantication
    }
    
    public func start(){
        // Step 3: initalise and configure CLLocationManager
        manager.delegate = self
        manager.headingFilter = 3
        //manager.headingOrientation
        askPermission()
        if UIDevice.current.batteryState == .unplugged {
            manager.desiredAccuracy = kCLLocationAccuracyBest
        }
        else{
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
    }
    public func stop(){
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    public func reset(){
        stop()
        start()
    }
}

extension AppleLocationProvider: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied: // Setting option: Never
            print("LocationManager didChangeAuthorization denied")
        case .notDetermined: // Setting option: Ask Next Time
            print("LocationManager didChangeAuthorization notDetermined")
            askPermission()
        case .authorizedWhenInUse: // Setting option: While Using the App
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
            // Stpe 6: Request a one-time location information
            self.manager.startUpdatingLocation()
            self.manager.startUpdatingHeading()
        case .authorizedAlways: // Setting option: Always
            print("LocationManager didChangeAuthorization authorizedAlways")
            // Stpe 6: Request a one-time location information
            self.manager.startUpdatingLocation()
            self.manager.startUpdatingHeading()
        case .restricted: // Restricted by parental control
            print("LocationManager didChangeAuthorization restricted")
        default:
            print("LocationManager didChangeAuthorization")
        }
    }
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }
    // Step 7: Handle the location information
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("LocationManager didUpdateLocations: numberOfLocation: \(locations.count)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        locations.forEach { (location) in
//            print ("======================")
//            print("LocationManager didUpdateLocations: \(dateFormatter.string(from: location.timestamp)); \(location.coordinate.latitude), \(location.coordinate.longitude)")
//            print("LocationManager altitude: \(location.altitude)")
//            print("LocationManager floor?.level: \(location.floor?.level ?? 0)")
//            print("LocationManager horizontalAccuracy: \(location.horizontalAccuracy)")
//            print("LocationManager verticalAccuracy: \(location.verticalAccuracy)")
//            print("LocationManager speedAccuracy: \(location.speedAccuracy)")
//            print("LocationManager speed: \(location.speed)")
//            print("LocationManager timestamp: \(location.timestamp)")
//            if #available(iOS 13.4, *) {
//                print("LocationManager courseAccuracy: \(location.courseAccuracy)")
//            } else {
//                // Fallback on earlier versions
//            } // 13.4
//            print("LocationManager course: \(location.course)")
//            print ("======================")
            
            
            let locatinResponse = ["userInfo": ["latitude": location.coordinate.latitude,
                                                "longitude": location.coordinate.longitude,
                                                "altitude": location.altitude,
                                                "level": location.floor?.level ?? 0,
                                                "horizontalAccuracy": location.horizontalAccuracy,
                                                "verticalAccuracy": location.verticalAccuracy,
                                                "speedAccuracy": location.speedAccuracy,
                                                "speed": location.speed,
                                                "timestamp": location.timestamp,
                                                "course": heading]]
            NotificationCenter.default
                        .post(name: NSNotification.Name("com.woosmap.locationupdate"),
                         object: nil,
                         userInfo: locatinResponse)
        }
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
