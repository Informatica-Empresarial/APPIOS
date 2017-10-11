//
//  DKHServiceTabBarViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit


class DKHServiceTabBarViewController: DKHBaseTabBarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureTabBar() {
        super.configureTabBar()
        if DKHUser.isLoggedIn {
            var currentControllers = self.viewControllers
            if currentControllers?.count == 1 {
                currentControllers?.append(DKHNavigation.baseMyServicesNavigationController())
                currentControllers?.append(DKHNavigation.baseSettingsNavigationController())
                self.setViewControllers(currentControllers, animated: true)
            }
        }else {
            var currentControllers = self.viewControllers
            currentControllers?.removeLast()
            currentControllers?.removeLast()
            self.setViewControllers(currentControllers, animated: false)
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
