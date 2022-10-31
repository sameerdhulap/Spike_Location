//
//  SitumLocationProvider.swift
//  WoosmapProvider-Situm
//
//  Created by WGS on 28/10/22.
//

import UIKit
import CoreLocation
import SitumSDK

public class SitumLocationProvider: NSObject {
    public static let shared = SitumLocationProvider()
    let locationMgr: LocationChecker = WoosmapProvider_Situm.LocationChecker()
    var buildingInfo: [String:[String:Int]] = [:]
    
    public func credential(_ keys:[String:String]){
        let apikey: String = keys["API_KEY"] ?? ""
        let email: String = keys["API_EMAIL"] ?? ""
        SITServices.provideAPIKey(apikey, forEmail: email)
    }
    
    public func bulildingInfo( _ buildings:[String:[String:Int]]){
        self.buildingInfo = buildings
        //Check building format
//        for (_, floors) in buildings {
//            if floors is [String:Int] {
//                //Proper format
//            }
//            else{
//                let error = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "Building info not in proper format"])
//                throw error
//            }
//        }
    }
    
    public func start(){
        SITLocationManager.sharedInstance().delegate = self
        locationMgr.delegate = self
    }
    public func stop(){
        SITLocationManager.sharedInstance().removeUpdates()
    }
    public func reset(){
        stop()
        start()
    }
    
    fileprivate func situmRequest() {
        let request: SITLocationRequest = SITLocationRequest.init()
        request.useGlobalLocation = true
        request.useGps = true
        request.interval = 1000
        request.useLocationsCache = false
        request.useBarometer = false
        request.useDeadReckoning = false
        //request.realtimeUpdateInterval = .updateIntervalRealtime
        
        SITLocationManager.sharedInstance().requestLocationUpdates(request)
    }
    
}
extension SitumLocationProvider:SITLocationDelegate {
    
    public func locationManager(_ locationManager: SITLocationInterface, didUpdate location: SITLocation) {
        var level = "-99" //Ground
        if let buildingCapture = buildingInfo[location.position.buildingIdentifier]{
            if let indoorFloor = buildingCapture[location.position.floorIdentifier] {
                level = "\(indoorFloor)"
            }
        }
        
        
        let locatinResponse = ["userInfo": ["latitude": location.position.coordinate().latitude,
                                            "longitude": location.position.coordinate().longitude,
                                            "altitude": -1,
                                            "level": level,
                                            "horizontalAccuracy": location.accuracy,
                                            "verticalAccuracy": -1,
                                            "speedAccuracy": 0,
                                            "speed": 1,
                                            "timestamp": location.timestamp,
                                            "course": location.bearing]]
        
        
        NotificationCenter.default
                    .post(name: NSNotification.Name("com.woosmap.locationupdate"),
                     object: nil,
                     userInfo: locatinResponse)
    }
    public func locationManager(_ locationManager: SITLocationInterface, didFailWithError error: Error?) {
        print("error")
    }
    public func locationManager(_ locationManager: SITLocationInterface, didUpdate state: SITLocationState) {
        print("didUpdate")
    }
}
extension SitumLocationProvider: LocationCheckerProtocol {
    func LocationChecker(_ sender: LocationChecker, statusChange: CLAuthorizationStatus){
        
        switch statusChange {
        case .authorizedWhenInUse: // Setting option: While Using the App
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
            // Stpe 6: Request a one-time location information
            situmRequest()
        case .authorizedAlways: // Setting option: Always
            print("LocationManager didChangeAuthorization authorizedAlways")
            // Stpe 6: Request a one-time location information
            situmRequest()
        default:
            print("Ignore")
            //"Ignore"
        }
    }

    // Step 7: Handle the location information
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("LocationManager didUpdateLocations: numberOfLocation: \(locations.count)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        locations.forEach { (location) in
            
            let locatinResponse = ["userInfo": ["latitude": location.coordinate.latitude,
                                                "longitude": location.coordinate.longitude,
                                                "altitude": location.altitude,
                                                "level": location.floor?.level ?? -99,
                                                "horizontalAccuracy": location.horizontalAccuracy,
                                                "verticalAccuracy": location.verticalAccuracy,
                                                "speedAccuracy": location.speedAccuracy,
                                                "speed": location.speed,
                                                "timestamp": location.timestamp,
                                                "course": location.course]]
            NotificationCenter.default
                        .post(name: NSNotification.Name("com.woosmap.locationupdate"),
                         object: nil,
                         userInfo: locatinResponse)
        }
    }
}
