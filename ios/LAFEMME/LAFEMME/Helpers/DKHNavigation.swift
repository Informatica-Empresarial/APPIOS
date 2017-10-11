//
//  DKHNavigation.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import Foundation
import UIKit

class DKHNavigation {
    
    class func selectCityForService() -> DKHSelectCityViewController {
        return   UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DKHSelectCityViewController") as! DKHSelectCityViewController
    }
    
    class func onBoarding() -> DKHOnBoardingPageViewController {
        return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "DKHOnBoardingPageViewController") as! DKHOnBoardingPageViewController
    }
    
    class func onBoardingNavigation() -> UINavigationController {
         return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "OnBoardingNav") as! UINavigationController
    }
    
    class func firstPage() -> DKHFirstPageViewController {
        return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "DKHFirstPageViewController") as! DKHFirstPageViewController
    }
    
    class func secondPage() -> DKHSecondPageViewController {
        return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "DKHSecondPageViewController") as! DKHSecondPageViewController
    }
    
    class func thirdPage() -> DKHThirdPageViewController {
        return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "DKHThirdPageViewController") as! DKHThirdPageViewController
    }
    
    class func selectService() -> DKHServicesViewController {
        return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHServicesViewController") as! DKHServicesViewController
    }
    
    class func selectAddress() -> DKHSelectAddressViewController {
        return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHSelectAddressViewController") as! DKHSelectAddressViewController
    }
    
    
    class func selectWorker() -> DKHSelectWorkerViewController {
        return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHSelectWorkerViewController") as! DKHSelectWorkerViewController
    }
    
    class func selectWorkerAvailability() -> DKHWorkerAvailabilityViewController {
        return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHWorkerAvailabilityViewController") as! DKHWorkerAvailabilityViewController
    }
    
    
    class func loginNavigation() -> UINavigationController {
        return UIStoryboard(name:"Login",bundle:nil).instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
        
    }
    
    class func registerNavigation() -> UINavigationController {
        return UIStoryboard(name:"Register",bundle:nil).instantiateViewController(withIdentifier: "RegisterNavigation") as! UINavigationController
    }
    
    
    class func summaryViewCotroller() -> DKHSummaryViewController {
         return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHSummaryViewController") as! DKHSummaryViewController
    }
    
    class func baseMyServicesNavigationController() -> DKHBaseNavigationViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DKHBaseMyServicesNavigationViewController") as! DKHBaseNavigationViewController
    }
    
    class func baseSettingsNavigationController() -> DKHBaseNavigationViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DKHBaseSettingsNavigationViewController") as! DKHBaseNavigationViewController

    }
    
    class func rateService() -> UINavigationController {
        return UIStoryboard(name: "Service", bundle: nil).instantiateViewController(withIdentifier: "DKHBaseNavigationViewControllerRateService") as! DKHBaseNavigationViewController
    }
    
    
    class func navigationToAddressViewController() -> DKHNavigateToAddressViewController {
        return UIStoryboard(name:"Service",bundle:nil).instantiateViewController(withIdentifier: "DKHNavigateToAddressViewController") as! DKHNavigateToAddressViewController
    }
    
    
}
