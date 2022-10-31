//
//  ViewController.swift
//  Woosmap Location
//
//  Created by WGS on 27/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblFloor: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    let woosmapLocationManager = WoosmapLocationManager()
    
    @IBOutlet weak var lblInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        woosmapLocationManager.delegate = self
        
    }
}
extension ViewController: WoosmapLocationDelegate{
    func WoosmapLocation(_ sender: WoosmapLocationManager, _ location: WoosLocation) {
        lblLocation.text = "lat: \(location.coordinate.latitude ) \nlng:\(location.coordinate.longitude)"
        lblFloor.text = "\(location.indoorFloor)"
        lblInfo.text = location.description
    }
    
}
