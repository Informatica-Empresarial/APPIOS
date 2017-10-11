//
//  DKHBaseViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/11/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import RealReachability

class DKHBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupHomeButton(){
        self.navigationItem.rightBarButtonItem = Appearance.barButtonWithImage(image: UIImage(named: "menu"), target: self, action: #selector(homeAction(sender:)))
    }
    
    func setupBackButton(){
        let count: Int = navigationController?.viewControllers.count ?? 0
        if count > 0 && navigationItem.leftBarButtonItem == nil {
            if  !(navigationController?.viewControllers.first === self) {
                self.navigationItem.leftBarButtonItem = Appearance.barButtonWithImage(image: UIImage(named: "back"), target: self, action: #selector(self.backAction(sender:)))
            }
        }
    }
    
    func homeAction(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureAppearance() {
        //title   = "LA FEMME"
        setupBackButton()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func backAction(sender:AnyObject? = nil) {
       let _ = navigationController?.popViewController(animated: true)
        
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
