//
//  ViewController.swift
//  Woosmap Location
//
//  Created by WGS on 27/10/22.
//

import UIKit

class ViewController: UIViewController {

    let woosmapLocationManager = WoosmapLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        woosmapLocationManager.delegate = self
        
    }
}
extension ViewController: WoosmapLocationDelegate{
    func WoosmapLocation(_ sender: WoosmapLocationManager, _ location: WoosLocation) {
        print(location)
        
    }
    
}
