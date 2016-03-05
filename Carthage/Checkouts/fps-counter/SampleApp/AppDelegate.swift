//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Markus Gasser on 03.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import UIKit
import FPSCounter


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        FPSCounter.showInStatusBar(application)

        return true
    }
}

