//
//  AppDelegate.swift
//  Woosmap Location
//
//  Created by WGS on 27/10/22.
//

import UIKit
import WoosmapProvider_Apple
import WoosmapProvider_Situm

enum provider {
    case Apple
    case Situm
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Default Apple provider
        
        let chooseProvider: provider = .Situm
        switch chooseProvider {
        case .Apple:
            AppleLocationProvider.shared.start()
        case .Situm:
            SitumLocationProvider.shared.credential(["API_KEY":"<<Add your key>>",
                                                     "API_EMAIL":"<<Add your email>>"])
            SitumLocationProvider.shared.bulildingInfo(["11567":["35153":3]])
            SitumLocationProvider.shared.start()
        }
        
        
        //Situm

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

