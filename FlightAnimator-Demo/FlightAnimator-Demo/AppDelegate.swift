//
//  AppDelegate.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//
import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var baseViewController: ViewController = ViewController()
    var baseNavViewController: UINavigationController = UINavigationController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.baseNavViewController.view.backgroundColor = UIColor.whiteColor()
        baseNavViewController.setNavigationBarHidden(true, animated: false)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        baseNavViewController.pushViewController(baseViewController, animated: false)
        window?.rootViewController = self.baseNavViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    
    
}

