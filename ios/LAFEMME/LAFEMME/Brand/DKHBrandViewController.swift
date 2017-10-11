//
//  DKHBrandViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/25/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

class DKHBrandViewController: DKHBaseViewController {
    
    @IBOutlet weak var sosButton: UIButton!
    @IBOutlet weak var programButton: UIButton!
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    var selectedCity:DKHCity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTabBar), name: NSNotification.Name("tabBar"), object: nil)
        // locationManager.startUpdatingLocation()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "onBoarding")  {
            let onBoarding = DKHNavigation.onBoardingNavigation()
            self.navigationController?.present(onBoarding, animated: true, completion: nil)
        }
    }
    
    func refreshTabBar() {
        let baseTabbar = self.tabBarController as? DKHBaseTabBarViewController
        baseTabbar?.configureTabBar()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title                       = "LA FEMME"
        locationManager.delegate    =   self
        programButton.setTitle(NSLocalizedString("program_button", comment: ""), for: .normal)
        sosButton.setTitle(NSLocalizedString("sos_button", comment: ""), for: .normal)
        navigationItem.rightBarButtonItem = Appearance.barButtonWithTitle(title: NSLocalizedString("contact_us", comment: ""), textColor: UIColor.white, target: self, action: #selector(callLAFEMME))
        
    }
    
    
    func callLAFEMME() {
        if let url = URL(string: "tel://3163797233") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func programAction(_ sender: Any) {
        
        if !DKHUser.isLoggedIn {
            let loginNavigation = DKHNavigation.loginNavigation()
            let loginViewController = loginNavigation.topViewController as! DKHLoginViewController
            
            navigationController?.present(loginNavigation, animated: true, completion: nil)
            
            loginViewController.loginClosure = { user, error in
                guard let user = user, error == nil else {
                    SVProgressHUD.showInfo(withStatus: error?.localizedDescription)
                    return
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                self.registerDevice()
                
                if user.userRole == .ServiceSpecialistUser {
                    let storyboard:UIStoryboard = UIStoryboard(name: "WorkerMain", bundle: nil)
                    let workerTabbar:UITabBarController = storyboard.instantiateViewController(withIdentifier: "DKHWorkerTabBarViewController") as! UITabBarController
                    let workerHomeNav           = workerTabbar.viewControllers?.first as? UINavigationController
                    let workerHome              = workerHomeNav?.topViewController as? DKHWorkerHomeViewController
                    workerHome?.userLocation    = self.currentLocation
                    
                    appDelegate.window?.rootViewController = workerTabbar
                }
                
                (self.tabBarController as? DKHBaseTabBarViewController)?.configureTabBar()
                //self.globalSettings()
                SVProgressHUD.showSuccess(withStatus: "\(NSLocalizedString("welcome_message",comment: "")) \(user.firstname)")
               
            }
        }else {
            
            let city                    = DKHNavigation.selectCityForService()
            city.userLocation           = currentLocation
            
            self.navigationController?.pushViewController(city, animated:true)
        }
    }
    
    
    
    @IBAction func sosAction(_ sender: Any) {
        if !DKHUser.isLoggedIn {
            let loginNavigation = DKHNavigation.loginNavigation()
            let loginViewController = loginNavigation.topViewController as! DKHLoginViewController
            
            navigationController?.present(loginNavigation, animated: true, completion: nil)
            
            loginViewController.loginClosure = { user, error in
                guard let user = user, error == nil else {
                    return
                }
                (self.tabBarController as? DKHServiceTabBarViewController)?.configureTabBar()
                self.globalSettings()
                SVProgressHUD.showSuccess(withStatus: "\(NSLocalizedString("welcome_message",comment: "")) \(user.firstname)")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            
            
        }else {
            let addressViewController               = DKHNavigation.selectAddress()
            addressViewController.selectedCity      = selectedCity
            let serviceSummary                      = DKHServiceSummary()
            serviceSummary.sosSearch                = true
            addressViewController.serviceSummary    = serviceSummary
            
            self.navigationController?.pushViewController(addressViewController, animated:true)
        }
        
    }
    
    private func globalSettings() {
        DKHGlobalSettings.all(endPoint: DKHEndPoint.globalSettings()) { _ in }
    }
    
    private func registerDevice() {
        guard let token = UserDefaults.standard.object(forKey: "deviceToken") as? String  else {
            return
        }
        DKHUser.registerDevice(endPoint: .registerDevice(deviceToken: token)) { (success) in
            print(success)
        }
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension DKHBrandViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        currentLocation = manager.location?.coordinate
        manager.stopUpdatingLocation()
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        currentLocation = manager.location?.coordinate
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
    }
    
}
