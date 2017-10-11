//
//  AppDelegate.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/7/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import RealReachability
import UserNotifications
import RealmSwift
import ObjectMapper
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let options = launchOptions {
            if let payload = options[UIApplicationLaunchOptionsKey.remoteNotification]  as? [String:Any]{
                handleNotification(jsonResponse: payload)
                // Do what you want to happen when a remote notification is tapped.
            }
            //handleNotification(jsonResponse: options)
        }
        Fabric.with([Crashlytics.self])
        Appearance.configureAppAppearance()
        RealReachability.sharedInstance().startNotifier()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        registerForRemoteNotification(application: application)
        if DKHUser.isLoggedIn {
            if let user = DKHUser.currentUser {
                
                if user.userRole == .ServiceSpecialistUser {
                    let storyboard:UIStoryboard = UIStoryboard(name: "WorkerMain", bundle: nil)
                    let workerTabbar:UITabBarController = storyboard.instantiateViewController(withIdentifier: "DKHWorkerTabBarViewController") as! UITabBarController
                    
                    self.window?.rootViewController = workerTabbar
                }else {
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let workerTabbar:UITabBarController = storyboard.instantiateViewController(withIdentifier: "DKHServiceTabBarViewController") as! UITabBarController
                    self.window?.rootViewController = workerTabbar
                }
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        //        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handle(url,
        //                                                                                                                                                                                                sourceApplication: sourceApplication,
        //                                                                                                                                                                                annotation: annotation)
    }
    
    
    
    func registerForRemoteNotification(application:UIApplication) {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            
            center.requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { granted, error in
                if error == nil {
                    application.registerForRemoteNotifications()
                }
                
            })
        }
        else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("**************************************************")
        print("DEVICE TOKEN = \(deviceToken)")
        NSLog("DEVICE TOKEN = \(deviceToken)")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NSLog("TOKEN FEMME %@", token)
        UserDefaults.standard.setValue(token, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("fallo")
    }
    
    func handleNotification(jsonResponse:[String:Any]) {
        
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
        let action = jsonResponse["action"] as? String
        if let appointment = jsonResponse["appointment"] as? [String:Any] {
            if let appointment = Mapper<DKHServiceAppointment>().map(JSON: appointment) {
                if let action = action {
                    if action == "newAppointment" {
                        presentAppointment(appointment: appointment)
                    }else if action == "rate" {
                        let rateNavViewController       = DKHNavigation.rateService()
                        let rateViewController          = rateNavViewController.topViewController as? DKHRateServiceViewController
                        rateViewController?.appointment = appointment
                        self.window?.rootViewController?.present(rateNavViewController, animated: true, completion: nil)
                    }else if action == "appointmentCancelled" {
                        presentAppointment(appointment: appointment)
                    }else if action == "sos" {
                        DKHWorkerSos.shared.shouldDisableSos = true
                        DKHUser.turnOffSOS(endPoint: .turnOffSOS(), closure: { (success) in})
                        presentAppointment(appointment: appointment)
                    }
                }
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let jsonResponse = response.notification.request.content.userInfo["data"] as? [String:Any] {
            NSLog("aquiiiii")
            handleNotification(jsonResponse: jsonResponse)
            completionHandler()
        }
        
        if response.notification.request.identifier == "sos" {
            if DKHWorkerSos.shared.isSOSOn {
                DKHWorker.activateSOS(endPoint: .tongleSOS(location: nil)) { (worker, error) in
                    if error == nil {
                        DKHWorkerSos.shared.isSOSOn = false
                        DKHWorkerSos.shared.locationTimer.invalidate()
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        DKHWorkerSos.shared.shouldDisableSos = true
                        Realm.update(updateClosure: { (realm) in
                            if  let user = realm.objects(DKHUser.self).first {
                                user.SOS   = false
                                realm.add(user, update: true)
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func presentAppointment(appointment:DKHServiceAppointment) {
        let appointmentDetail = DKHNavigation.summaryViewCotroller()
        appointmentDetail.appointment = appointment
        let baseViewController = DKHBaseNavigationViewController(rootViewController: appointmentDetail)
        baseViewController.colorNavBar = "program"
        appointmentDetail.setupHomeButton()
        appointmentDetail.cancelAppointmentClosure = {
            self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        self.window?.rootViewController?.present(baseViewController, animated: true, completion: nil)
    }
    
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        //Handle the notification
        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])
    }
}

