//
//  WoosmapLocationManager.swift
//  Woosmap Location
//
//  Created by WGS on 27/10/22.
//

import Foundation
import CoreLocation
class WoosLocation:CLLocation {
    var indoorFloor: String
    
    init(indoorFloor: String) {
        self.indoorFloor = indoorFloor
        super.init()
    }
    fileprivate static func toDouble(_ value:Any?) -> Double{
        if let convert = value as? Double {
            return convert
        }
        if let convert = value as? Float {
            return Double(convert)
        }
        return 99
    }
    init(location: [String:Any]) {
        self.indoorFloor = location["level"] as? String ?? "-99"
        let latitude:Double = WoosLocation.toDouble(location["latitude"])
        let longitude:Double = WoosLocation.toDouble(location["longitude"])
        let altitude:Double = WoosLocation.toDouble(location["altitude"])
        let horizontalAccuracy:Double = WoosLocation.toDouble(location["horizontalAccuracy"])
        let verticalAccuracy:Double = WoosLocation.toDouble(location["verticalAccuracy"] )
        let speedAccuracy:Double = WoosLocation.toDouble(location["speedAccuracy"])
        let speed:Double = WoosLocation.toDouble(location["speed"])
        let course:Double = WoosLocation.toDouble(location["course"])

        if #available(iOS 13.4, *) {
            super.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                       altitude: altitude,
                       horizontalAccuracy: horizontalAccuracy,
                       verticalAccuracy: verticalAccuracy,
                       course: CLLocationDirection(course),
                       courseAccuracy: -1,
                       speed: speed,
                       speedAccuracy: speedAccuracy,
                       timestamp: Date())
        } else {
            // Fallback on earlier versions
            super.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                       altitude: altitude,
                       horizontalAccuracy: horizontalAccuracy,
                       verticalAccuracy:verticalAccuracy ,
                       timestamp: Date())
        }

    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override var description: String {
        return "\(super.description ) Indoor Floor: \(indoorFloor)"
    }
    
}

protocol WoosmapLocationDelegate {
    func WoosmapLocation(_ sender: WoosmapLocationManager, _ location: WoosLocation)
    
}
extension NSNotification.Name{
    static let LocationUpdate = Notification.Name("com.woosmap.locationupdate")
}
class WoosmapLocationManager {
    
    var delegate: WoosmapLocationDelegate?
    
    init(){
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(locationUpdate),
                                       name: NSNotification.Name.LocationUpdate,
                                       object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func locationUpdate(_ notification: Notification){
        if let locationInfo = notification.userInfo?["userInfo"] as? [String: Any] {
            //print(locationInfo)
            let woosLocation: WoosLocation = WoosLocation.init(location: locationInfo)
            delegate?.WoosmapLocation(self, woosLocation)
        }
    }
    
}
