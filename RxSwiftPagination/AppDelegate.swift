//
//  AppDelegate.swift
//  RxSwiftPagination
//
//  Created by Ferhan Akkan on 11.07.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = PaginationViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

