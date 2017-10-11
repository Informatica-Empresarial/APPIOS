
//
//  DKHWorkerTabBarViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/29/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHWorkerTabBarViewController: DKHBaseTabBarViewController {
    
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
        
        if !DKHUser.isLoggedIn {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
            let root        =   storyBoard.instantiateViewController(withIdentifier: "DKHServiceTabBarViewController")
            appDelegate.window?.rootViewController = root
            
        }else {
            let settings = DKHNavigation.baseSettingsNavigationController()
            var currentViewControllers = self.viewControllers
            currentViewControllers?.append(settings)
            self.setViewControllers(currentViewControllers, animated: true)
        }
    }
    
}
