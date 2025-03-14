//
//  AppDelegate.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController = homeVC
        window?.makeKeyAndVisible()
        return true
    }
}
