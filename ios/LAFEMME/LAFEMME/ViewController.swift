//
//  ViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/7/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let login = FBSDKLoginButton()
        login.readPermissions = ["public_profile", "email", "user_friends","user_birthday"]
        login.center    = self.view.center
        login.delegate = self
        
        DKHUser.login(endPoint: DKHEndPoint.login(email: "", password: "")) { (user, error) in
            
            
            //print(error)
        }
        
        self.view.addSubview(login)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil) {
                    //print(result)
                }
            })
        }
        
    }
    
    
    
    
    
    
    
}

