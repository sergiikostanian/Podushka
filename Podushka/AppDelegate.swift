//
//  AppDelegate.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let dependencyManager = DependencyManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        dependencyManager.setupContainer(as: .normal)
        
        let mapVC = window?.rootViewController as! MainVC
        mapVC.setupDependencies(with: dependencyManager)

        let bgService: BackgroundService = try! dependencyManager.resolve()

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.sk.podushka.alarmTask", using: nil) { (task) in
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            bgService.handleAlarmBackgroundTask()
            task.setTaskCompleted(success: true)
        }

        return true
    }
    
}

